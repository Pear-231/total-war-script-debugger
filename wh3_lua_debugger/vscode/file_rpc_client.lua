-- file_rpc_client.lua

-- 0) Paths to your game directory
local GAME_ROOT     = "D:/SteamLibrary/steamapps/common/Total War WARHAMMER III/"
local SNIPPET_PATH  = GAME_ROOT .. "vscode_snippet.lua"
local RESPONSE_PATH = GAME_ROOT .. "vscode_stub_response.txt"
local JSON_TIMEOUT  = 3  -- seconds

-- 1) Load rxi/json.lua
local json = require("wh3_lua_debugger.vscode.rxi_json")

-- 2) JSON‐RPC client definition
local client = {}
client.__index = client

-- Helper to build a proxy for interface objects
local function make_proxy(rpc_instance, id)
  return setmetatable({ __id = id, __rpc = rpc_instance }, {
    __index = function(self, method_name)
      -- return a function that calls invoke_interface on *this* rpc_instance
      return function(_, ...)
        return rpc_instance:call("invoke_interface", {
          { __iface = true, id = self.__id },
          method_name,
          { ... }
        })
      end
    end
  })
end

-- Constructor
function client.new(timeout)
  return setmetatable({
    timeout = timeout or JSON_TIMEOUT,
    next_id = 1,
  }, client)
end

-- Send JSON-RPC request
function client:send_request(req)
  os.remove(RESPONSE_PATH)
  local payload = json.encode(req)
  local f, err = io.open(SNIPPET_PATH, "w")
  if not f then error(("Could not open snippet file '%s': %s"):format(SNIPPET_PATH, tostring(err))) end
  f:write(payload)
  f:close()
end

-- Receive and decode JSON-RPC response
function client:recv_response()
  local start = os.time()
  while os.time() - start < self.timeout do
    local rf = io.open(RESPONSE_PATH, "r")
    if rf then
      local raw = rf:read("*a")
      rf:close()
      os.remove(RESPONSE_PATH)
      local resp = json.decode(raw)
      -- if it's an interface descriptor, return a proxy bound to this client
      if type(resp.result) == "table" and resp.result.__iface then
        return make_proxy(self, resp.result.id)
      end
      return resp.result
    end
    -- 1s busy‐wait
    local t0 = os.time() while os.time() == t0 do end
  end
  error(("RPC timeout after %d seconds (no response at %s)"):format(self.timeout, RESPONSE_PATH))
end

-- Public API: call(method, params) → result (or proxy)
function client:call(method, params)
  local id = self.next_id
  self.next_id = id + 1

  local req = {
    jsonrpc = "2.0",
    method  = method,
    params  = params or {},
    id      = id,
  }

  self:send_request(req)
  local result = self:recv_response()
  return result
end

return client
