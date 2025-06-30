local bridge = require("script._lib.mod.bridge")

cm:add_pre_first_tick_callback(
    function()
        cm:repeat_real_callback(
            function()
                bridge.execute_bridge_file()
            end,
            50,
            "VSCodeBridge"
        )
    end
)