local registry = require("ldbg_interface_registry")

local dispatcher = {}

local function call_interface(description, fn, parameters)
  local interface_object = registry.unwrap(description)
  if not interface_object then
    return nil, "Unknown interface ID " .. tostring(description.id)
  end

  local interface_function = interface_object[fn]
  if type(interface_function) ~= "function" then
    return nil, "No such interface function: " .. fn
  end

  local success, response = pcall(interface_function, interface_object, unpack(parameters or {}))
  if not success then
    return nil, response
  elseif type(response) == "userdata" then
    return registry.wrap(response)
  else
    return response
  end
end

local function call_cm(fn, parameters)
  local cm_function = cm[fn]
  if type(cm_function) ~= "function" then
    return nil, "No such cm function: " .. tostring(fn)
  end

  local success, response = pcall(cm_function, cm, unpack(parameters or {}))
  if not success then
    return nil, response
  elseif type(response) == "userdata" then
    return registry.wrap(response)
  else
    return response
  end
end

function dispatcher.handle(request)
  local response = { jsonrpc = "2.0", id = request.id }
  local result, error_message

  if request.method == "invoke_interface" then
    result, error_message = call_interface(
      request.params[1], request.params[2], request.params[3]
    )
  else
    result, error_message = call_cm(request.method, request.params)
  end

  if error_message then
    response.error  = { code = -32601, message = error_message }
  else
    response.result = result
  end

  return response
end

return dispatcher
