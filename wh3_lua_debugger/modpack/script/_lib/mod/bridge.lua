local bridge = {}

local BRIDGE_FILE   = "vscode_snippet.lua"
local RESPONSE_FILE = "vscode_stub_response.txt"

local json = pcall(require, "rxi_json")

-- Ensure math.huge exists
if type(math) ~= "table" then
  _G.math = { huge = 1/0, pi = 3.141592653589793 }
elseif math.huge == nil then
  math.huge = 1/0
end




--------------------------------------------------------------------------------
-- 3) Lua 5.1 unpack
--------------------------------------------------------------------------------
---@diagnostic disable-next-line deprecated
local unpack_f = rawget(_G, "unpack") or table.unpack

--------------------------------------------------------------------------------
-- 4) Interface registry
--------------------------------------------------------------------------------
local next_obj_id  = 1
local obj_registry = {}

local function wrap_interface(obj)
  local id = next_obj_id
  next_obj_id = id + 1
  obj_registry[id] = obj
  return { __iface = true, id = id }
end

local function unwrap_interface(desc)
  return obj_registry[desc.id]
end

--------------------------------------------------------------------------------
-- 5) Safe JSON-RPC response writer
--------------------------------------------------------------------------------
local function send_response(resp)
  local f, err = io.open(RESPONSE_FILE, "w")
  if not f then
    out("[VSCodeBridge] ERROR opening " .. RESPONSE_FILE .. ": " .. tostring(err))
    return
  end
  -- by now resp.result is guaranteed not to be userdata
  f:write(json.encode(resp))
  f:close()
  out("[VSCodeBridge] wrote JSON-RPC response id=" .. tostring(resp.id))
end

--------------------------------------------------------------------------------
-- 6) Main execution loop
--------------------------------------------------------------------------------
function bridge.execute_bridge_file()
  -- Read incoming JSON-RPC request
  local f = io.open(BRIDGE_FILE, "r")
  if not f then return end
  local raw = f:read("*a")
  f:close()
  if not raw:match("%S") then return end

  -- Parse request
  local ok_req, req = pcall(json.decode, raw)
  if not ok_req or type(req) ~= "table" or not req.method then
    out("[VSCodeBridge] invalid JSON-RPC payload, skipping")
    return
  end

  local resp   = { jsonrpc = "2.0", id = req.id }
  local result, err_msg

  -- Dispatch either invoke_interface or direct cm:METHOD
  if req.method == "invoke_interface" then
    -- params = { iface_desc, method_name, args_array }
    local iface_desc, mname, args = unpack_f(req.params or {})
    local obj = unwrap_interface(iface_desc)
    if not obj then
      err_msg = "Unknown interface ID "..tostring(iface_desc.id)
    else
      local fn = obj[mname]
      if type(fn) ~= "function" then
        err_msg = "No such method: "..mname
      else
        local ok2, ret = pcall(fn, obj, unpack_f(args))
        if ok2 then
          -- wrap userdata interfaces
          if type(ret) == "userdata" then
            result = wrap_interface(ret)
          else
            result = ret
          end
        else
          err_msg = ret
        end
      end
    end

  else
    -- regular cm:METHOD(...)
    local fn = cm[req.method]
    if type(fn) ~= "function" then
      err_msg = "No such method: "..tostring(req.method)
    else
      local ok2, ret = pcall(fn, cm, unpack_f(req.params or {}))
      if ok2 then
        if type(ret) == "userdata" then
          result = wrap_interface(ret)
        else
          result = ret
        end
      else
        err_msg = ret
      end
    end
  end

  -- Build and send the response
  if err_msg then
    resp.error = { code = -32601, message = err_msg }
  else
    resp.result = result
  end
  send_response(resp)
end

return bridge
