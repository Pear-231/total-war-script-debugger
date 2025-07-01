local config = require("wh3_lua_debugger.vscode.config")
local client = require("wh3_lua_debugger.vscode.client").new(config.RCP_TIMEOUT)

local function make_proxy(global_name, use_self)
  return setmetatable({}, {
    __index = function(_, method_name)
      if use_self then
        -- colon-style: function(self, ...) e.g. 'core:
        return function(_, ...)
          return client:call("invoke_scripting_class", {
            global_name,
            method_name,
            { ... },
            true
          })
        end
      else
        -- dot-style: function(...) e.g. 'common.'
        return function(...)
          return client:call("invoke_scripting_class", {
            global_name,
            method_name,
            { ... },
            false
          })
        end
      end
    end
  })
end

_G.cm = make_proxy("cm", true )
_G.core = make_proxy("core", true )
_G.common = make_proxy("common", false) -- uses '.' instead of ':'

return {
  cm     = _G.cm,
  core   = _G.core,
  common = _G.common,
}
