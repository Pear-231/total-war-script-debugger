local transporter  = require("script._lib.mod.ldbg_transporter")
local dispatcher = require("script._lib.mod.ldbg_dispatcher")

local bridge = {}

function bridge.poll()
  local request = transporter.read_request()
  if not request then 
    return 
  end
  out("[WH3 Lua Debugger] Request: \n" .. request)

  local success, parsed_request = pcall(require("rxi_json").decode, request)
  if not success or type(parsed_request) ~= "table" then
    out("[WH3 Lua Debugger] Invalid JSON payload; skipping")
    return
  end

  out(string.format(
    "[WH3 Lua Debugger] Parsed request: method=%s, params=%s, id=%s",
    tostring(parsed_request.method),
    require("rxi_json").encode(parsed_request.params or {}),
    tostring(parsed_request.id)
  ))

  local response = dispatcher.handle(parsed_request)
  transporter.send_response(response)
end

return bridge
