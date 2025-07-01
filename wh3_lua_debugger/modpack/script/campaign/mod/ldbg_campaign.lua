local bridge = require("script._lib.mod.ldbg_bridge")
local config = require("script._lib.mod.ldbg_config")

if core:is_campaign() then
    cm:add_pre_first_tick_callback(
        function()
            out("[WH3 Lua Debugger] Adding LuaDebuggerCampaign callback")
            cm:repeat_real_callback(
                function()
                    _G.core = core
                    _G.cm = cm
                    _G.common = common
                    bridge.poll()
                end,
                config.POLL_INTERVAL,
                "LuaDebuggerCampaign"
            )
        end
    )
end