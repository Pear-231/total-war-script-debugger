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

local function call_scripting_class(scripting_class_name, function_name, params)
  local scripting_class = _G[scripting_class_name]
  if not scripting_class then
    return nil, "Unknown global object: " .. tostring(scripting_class_name)
  end

  local class_function = scripting_class[function_name]
  if type(class_function) ~= "function" then
    return nil, string.format("No such function on %s: %s", scripting_class_name, function_name)
  end

  local success, result = pcall(class_function, scripting_class, unpack(params or {}))
  if not success then
    return nil, result
  elseif type(result) == "userdata" then
    return registry.wrap(result)
  else
    return result
  end
end

function dispatcher.handle(request)
  local response = { jsonrpc = "2.0", id = request.id }
  local result, error

  if request.method == "invoke_interface" then
    result, error = call_interface(
      request.params[1], request.params[2], request.params[3]
    )
  elseif request.method == "invoke_scripting_class" then
    result, error = call_scripting_class(
      request.params[1],  -- scripting class e.g. cm
      request.params[2],  --  function name
      request.params[3]   -- table of parameters
    )
  end

  if error then
    response.error = { code = -32601, message = error }
  else
    response.result = result
  end

  return response
end

return dispatcher