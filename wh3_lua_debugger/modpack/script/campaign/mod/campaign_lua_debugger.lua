local bridge = require("script._lib.mod.bridge")
local config     = require("rpc_config")

cm:add_pre_first_tick_callback(
    function()
        cm:repeat_real_callback(
            function()
                bridge.execute_bridge_file()
            end,
            config.POLL_INTERVAL,
            "VSCodeBridge"
        )
    end
)