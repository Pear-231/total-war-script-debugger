local config = require("rpc_config")
local json_ok, json = pcall(require, "rxi_json")
assert(json_ok, "rpc_transport needs rxi_json.lua")

local transport = {}

function transport.read_request()
  local f = io.open(config.BRIDGE_FILE, "r")
  if not f then return end
  local raw = f:read("*a")
  f:close()
  if raw:match("%S") then return raw end
end

function transport.send_response(resp_obj)
  local f, err = io.open(config.RESPONSE_FILE, "w")
  if not f then
    out("[VSCodeBridge] ERROR opening " .. config.RESPONSE_FILE .. ": " .. tostring(err))
    return
  end
  f:write(json.encode(resp_obj))
  f:close()
  out("[VSCodeBridge] wrote JSON-RPC response id=" .. tostring(resp_obj.id))
end

return transport
