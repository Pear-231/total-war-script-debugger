-- file_rpc_client.lua

-- 0) Configure these to point at your TW:W3 install:
local GAME_ROOT     = "D:/SteamLibrary/steamapps/common/Total War WARHAMMER III/"
local SNIPPET_PATH  = GAME_ROOT .. "vscode_snippet.lua"
local RESPONSE_PATH = GAME_ROOT .. "vscode_stub_response.txt"
local JSON_TIMEOUT  = 3  -- seconds

-- 1) Load rxi's JSON module
local json = require("wh3_lua_debugger.vscode.rxi_json")

-- 2) JSON-RPC over files client
local client = {}
client.__index = client

-- Create a new client with its own ID counter
function client.new(timeout)
  return setmetatable({
    timeout = timeout or JSON_TIMEOUT,
    next_id = 1,
  }, client)
end

-- Send JSON-RPC request (and clear any stale response first)
function client:send_request(request)
  -- remove any leftover response
  os.remove(RESPONSE_PATH)

  local payload = json.encode(request)
  local f, err = io.open(SNIPPET_PATH, "w")
  if not f then
    error(("Could not open snippet file '%s': %s"):format(SNIPPET_PATH, tostring(err)))
  end
  f:write(payload)
  f:close()
  -- debug
  print(("[RPC] Wrote request id=%d to %s"):format(request.id, SNIPPET_PATH))
end

-- Wait for and read the JSON-RPC response
function client:recv_response()
  local start = os.time()
  while os.time() - start < self.timeout do
    local rf = io.open(RESPONSE_PATH, "r")
    if rf then
      local raw = rf:read("*a")
      rf:close()
      os.remove(RESPONSE_PATH)
      -- debug
      print(("[RPC] Read response from %s"):format(RESPONSE_PATH))
      return json.decode(raw)
    end
    -- simple 1s busy-wait
    local t0 = os.time() while os.time() == t0 do end
  end
  error(("RPC timeout after %d seconds (no response at %s)"):format(self.timeout, RESPONSE_PATH))
end

-- Public API: call(method, params) → result
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
  local resp = self:recv_response()

  if resp.id ~= id then
    error(("Mismatched response id: expected %d got %s"):format(id, tostring(resp.id)))
  end
  if resp.error then
    error(("RPC error: %s"):format(json.encode(resp.error)))
  end

  return resp.result
end

return client
