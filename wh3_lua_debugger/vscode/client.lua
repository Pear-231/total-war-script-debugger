local json = require("wh3_lua_debugger.vscode.rxi_json")
local config = require("wh3_lua_debugger.vscode.config")

local client = {}

client.__index = client

local function make_proxy(rpc_instance, id)
  return setmetatable({ __id = id, __rpc = rpc_instance }, {
    __index = function(self, method_name)
      return function(_, ...)
        return rpc_instance:call("invoke_interface", {
          { __interface = true, id = self.__id },
          method_name,
          { ... }
        })
      end
    end
  })
end

function client.new(timeout)
  return setmetatable({
    timeout = timeout or config.RCP_TIMEOUT,
    next_id = 1,
  }, client)
end

function client:send_request(req)
  os.remove(config.RESPONSE_PATH)
  local payload = json.encode(req)
  local file, error_message = io.open(config.REQUEST_PATH, "w")
  if not file then
    error(("Could not open snippet file '%s': %s"):format(config.REQUEST_PATH, tostring(error_message)))
  end
  file:write(payload)
  file:close()
end

function client:receive_response()
  local start = os.time()
  while os.time() - start < self.timeout do
    local response_file = io.open(config.RESPONSE_PATH, "r")
    if response_file then
      local raw = response_file:read("*a")
      response_file:close()
      os.remove(config.RESPONSE_PATH)

      local response = json.decode(raw)
      if type(response.result) == "table" and response.result.__interface then
        return make_proxy(self, response.result.id)
      end

      return response.result
    end
    local t0 = os.time()
    while os.time() == t0 do end
  end
  error(("RPC timeout after %d seconds (no response at %s)"):format(self.timeout, config.RESPONSE_PATH))
end

function client:call(method, params)
  local id = self.next_id; self.next_id = id + 1
  local request = { jsonrpc = "2.0", method = method, params = params or {}, id = id }
  self:send_request(request)
  return self:receive_response()
end

return client
