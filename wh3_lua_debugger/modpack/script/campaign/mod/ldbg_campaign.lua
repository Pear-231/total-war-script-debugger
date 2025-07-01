local gatekeeper = require("script._lib.mod.ldbg_gatekeeper")
local config = require("script._lib.mod.ldbg_config")

cm:add_pre_first_tick_callback(
    function()
        out("[WH3 Lua Debugger] Hooking campaign gatekeeper")
        cm:repeat_real_callback(
            function()
                gatekeeper.poll()
            end,
            config.POLL_INTERVAL,
            "LuaDebuggerCampaign"
        )
    end
)