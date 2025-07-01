local storage = require("rpc_storage")

---@diagnostic disable-next-line deprecated
local unpack_f = rawget(_G, "unpack") or table.unpack

local dispatcher = {}

function dispatcher.handle(req)
  local resp    = { jsonrpc = "2.0", id = req.id }
  local result, err_msg

  if req.method == "invoke_interface" then
    local desc, mname, args = unpack_f(req.params or {})
    local obj = storage.unwrap(desc)
    if not obj then
      err_msg = "Unknown interface ID " .. tostring(desc.id)
    else
      local fn = obj[mname]
      if type(fn) ~= "function" then
        err_msg = "No such method: " .. mname
      else
        local ok2, ret = pcall(fn, obj, unpack_f(args))
        if not ok2 then err_msg = ret
        else
          if type(ret) == "userdata" then
            result = storage.wrap(ret)
          else
            result = ret
          end
        end
      end
    end

  else
    local fn = cm[req.method]
    if type(fn) ~= "function" then
      err_msg = "No such method: " .. tostring(req.method)
    else
      local ok2, ret = pcall(fn, cm, unpack_f(req.params or {}))
      if not ok2 then err_msg = ret
      else
        if type(ret) == "userdata" then
          result = storage.wrap(ret)
        else
          result = ret
        end
      end
    end
  end

  if err_msg then
    resp.error = { code = -32601, message = err_msg }
  else
    resp.result = result
  end

  return resp
end

return dispatcher
