require("wh3_lua_debugger.vscode.campaign_manager_rpc")

function table_contains(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then return true end
    end
    return false
end

local faction_key = cm:get_local_faction_name()
out("[VSCodeTest] faction = " .. faction_key)

local faction = cm:get_faction(faction_key)
out("[VSCodeTest] faction = " .. faction:name())

local human_factions = cm:get_human_factions()
out("[VSCodeTest] humans = " .. table.concat(human_factions, ", "))

if table_contains(human_factions, faction_key) then
    out("[VSCodeTest] " .. faction_key .. " is a human faction")
else
    out("[VSCodeTest] " .. faction_key .. " is not a human faction")
end
