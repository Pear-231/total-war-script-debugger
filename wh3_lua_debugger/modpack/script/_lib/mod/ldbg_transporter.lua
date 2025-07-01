local config = require("script._lib.mod.ldbg_config")
local json = require("rxi_json")

local transporter = {}

function transporter.read_request()
  local file = io.open(config.REQUEST_FILE, "r")
  if not file then 
    return 
  end

  local request = file:read("*a")
  file:close()

  if request:match("%S") then
    os.remove(config.REQUEST_FILE)
    return request
  end
end

function transporter.send_response(resp)
  local payload = json.encode(resp)

  local file, error = io.open(config.RESPONSE_FILE, "w")
  if not file then
    out("[WH3 Lua Debugger] Error opening " .. config.RESPONSE_FILE .. ": " .. tostring(error))
    return
  end
  
  file:write(payload)
  file:close()

  out("[WH3 Lua Debugger] Response: " .. payload)
end

return transporter
