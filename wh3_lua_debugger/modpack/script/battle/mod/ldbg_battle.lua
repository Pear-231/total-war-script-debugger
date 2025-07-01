local bridge = require("script._lib.mod.ldbg_bridge")
local config = require("script._lib.mod.ldbg_config")

if core:is_battle() then
    bm:register_phase_change_callback(
        "Startup",
        function()
            out("[WH3 Lua Debugger] Adding LuaDebuggerBattle callback")
            bm:repeat_real_callback(
                function()
                    bridge.poll()
                end,
                config.POLL_INTERVAL,
                "LuaDebuggerBattle"
            )
        end
    )
end