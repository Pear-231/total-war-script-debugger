local bridge = {}

local transport  = require("rpc_transport")
local dispatcher = require("rpc_dispatcher")

---@diagnostic disable-next-line deprecated
local unpack_f = rawget(_G, "unpack") or table.unpack

-- Ensure math.huge exists for JSON encoding
if type(math) ~= "table" then
  _G.math = { huge = 1/0, pi = 3.141592653589793 }
elseif math.huge == nil then
  math.huge = 1/0
end

function bridge.execute_bridge_file()
  local raw = transport.read_request()
  if not raw then return end

  local ok, req = pcall(function() return require("rxi_json").decode(raw) end)
  if not ok or type(req) ~= "table" then
    out("[VSCodeBridge] invalid JSON-RPC payload, skipping")
    return
  end

  local resp = dispatcher.handle(req)
  transport.send_response(resp)
end

return bridge
