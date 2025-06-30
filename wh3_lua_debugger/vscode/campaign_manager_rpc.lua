-- campaign_manager_rpc.lua
-- Place this in your VSCode workspace alongside snippet.lua & file_rpc_client.lua

-- 1) Your JSON-RPC client, pointing at the game folder
local RPC = require("wh3_lua_debugger.vscode.file_rpc_client").new(3)  -- 3s timeout

-- 2) Stub out `out()` → `print()` locally
if type(out) ~= "function" then
  out = print
end

-- 3) Create a dynamic proxy for `cm`
local cm = setmetatable({}, {
  __index = function(self, method_name)
    -- create & cache a forwarder function
    local fn = function(_, ...)
      -- collect all args into an array
      local params = { ... }
      -- invoke via JSON-RPC; result is JSON-decoded (string/number/boolean/table)
      return RPC:call(method_name, params)
    end
    rawset(self, method_name, fn)
    return fn
  end
})

-- 4) Make it global so your snippets drop in unchanged
_G.cm = cm
return cm
