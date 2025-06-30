local faction_key = cm:get_local_faction_name()
out("[VSCodeTest] faction = " .. faction_key)

local faction = cm:get_faction(faction_key)
local faction_name = faction:name()
out("[VSCodeTest] faction from interface = " .. faction_name)

local human_factions = cm:get_human_factions()
out("[VSCodeTest] humans = " .. table.concat(human_factions, ", "))