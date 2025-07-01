local gatekeeper = require("script._lib.mod.ldbg_gatekeeper")
local config = require("script._lib.mod.ldbg_config")

bm:register_phase_change_callback(
    "Startup",
    function()
        out("[WH3 Lua Debugger] Hooking battle gatekeeper")
        bm:repeat_real_callback(
            function()
                gatekeeper.poll()
            end,
            config.POLL_INTERVAL,
            "LuaDebuggerBattle"
        )
    end
)