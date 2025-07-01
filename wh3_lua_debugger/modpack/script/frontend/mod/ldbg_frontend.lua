local bridge = require("script._lib.mod.ldbg_bridge")
local config = require("script._lib.mod.ldbg_config")

if core:is_frontend() then
    core:add_ui_created_callback(
        function()
            out("[WH3 Lua Debugger] Adding LuaDebuggerFrontend callback")
            tm:repeat_real_callback(
                function()
                    bridge.poll()
                end,
                config.POLL_INTERVAL,
                "LuaDebuggerFrontend"
            )
        end
    )
end