local faction_key = cm:get_local_faction_name()
out("[WH3 Lua Debugger] faction name: " .. faction_key)

local is_campaign = core:is_campaign()
out("[WH3 Lua Debugger] is campaign: " .. tostring(is_campaign))

if faction_key == "wh_main_emp_empire" then
    common.trigger_soundevent("Play_Nor_Throgg_Dip_Dwf_Greet_Neg_02")
end