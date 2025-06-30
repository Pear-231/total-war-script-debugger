local rpc = require("wh3_lua_debugger.vscode.file_rpc_client").new(3)

-- out proxy
if type(out) ~= "function" then out = print end

-- campaign_manager proxy
local cm = setmetatable({}, {
  __index = function(_, method)
    return function(_, ...)
      return rpc:call(method, { ... })
    end
  end
})

_G.cm = cm
return cm
