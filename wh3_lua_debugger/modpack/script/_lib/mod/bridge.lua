local bridge = {}

local bridge_file   = "vscode_snippet.lua"
local response_file = "vscode_stub_response.txt"

-- ─── Ensure math.huge exists ───────────────────────────────────────────────
-- Some sandboxed environments omit math.huge → json.lua errors out.
if type(math) ~= "table" then
  _G.math = { huge = 1/0, pi = 3.141592653589793 }
elseif math.huge == nil then
  math.huge = 1/0
end

-- ─── Load rxi/json.lua ─────────────────────────────────────────────────────
local ok, json = pcall(require, "rxi_json")
assert(ok, "bridge.lua requires rxi_json.lua (rxi) in the game root")

-- ─── unpack for Lua 5.1 compatibility ──────────────────────────────────────
---@diagnostic disable-next-line deprecated
local unpack_f = rawget(_G, "unpack") or table.unpack

-- ─── Helper: write a JSON-RPC response ────────────────────────────────────
local function send_response(resp)
  local f, err = io.open(response_file, "w")
  if not f then
    out("[VSCodeBridge] ERROR opening " .. response_file .. ": " .. tostring(err))
    return
  end
  f:write(json.encode(resp))
  f:close()
  out("[VSCodeBridge] wrote JSON-RPC response id=" .. tostring(resp.id))
end

-- ─── Main loop: check for requests, decode, dispatch, respond ─────────────
function bridge.execute_bridge_file()
  -- 1) read the request file
  local f = io.open(bridge_file, "r")
  if not f then return end
  local raw = f:read("*a")
  f:close()

  if not raw:match("%S") then
    return
  end

  -- 2) decode JSON-RPC request
  local ok_req, req = pcall(json.decode, raw)
  if not ok_req or type(req) ~= "table" or not req.method then
    out("[VSCodeBridge] invalid JSON-RPC payload, skipping")
    return
  end

  -- 3) dispatch to real cm method
  local result, err_msg
  local fn = cm[req.method]
  if type(fn) == "function" then
    local status, ret = pcall(fn, cm, unpack_f(req.params or {}))
    if status then
      result = ret
    else
      err_msg = ret
    end
  else
    err_msg = "No such method: " .. tostring(req.method)
  end

  -- 4) build response object
  local resp = { jsonrpc = "2.0", id = req.id }
  if err_msg then
    resp.error = { code = -32601, message = err_msg }
  else
    resp.result = result
  end

  -- 5) write it out
  send_response(resp)
end

return bridge