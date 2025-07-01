local gatekeeper = require("script._lib.mod.ldbg_gatekeeper")
local config = require("script._lib.mod.ldbg_config")

core:add_ui_created_callback(
    function()
        out("[WH3 Lua Debugger] Hooking frontend gatekeeper")
        tm:repeat_real_callback(
            function()
                gatekeeper.poll()
            end,
            config.POLL_INTERVAL,
            "LuaDebuggerFrontend"
        )
    end
)