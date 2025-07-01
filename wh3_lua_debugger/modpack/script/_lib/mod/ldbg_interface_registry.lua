local interface_registry = {}

local next_id   = 1
local registry  = {}

function interface_registry.wrap(obj)
  local id = next_id
  registry[id] = obj
  next_id = id + 1
  return { __interface = true, id = id }
end

function interface_registry.unwrap(desc)
  return registry[desc.id]
end

return interface_registry
