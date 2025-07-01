local storage = {}

local next_id   = 1
local registry  = {}

function storage.wrap(obj)
  local id = next_id
  registry[id] = obj
  next_id = id + 1
  return { __iface = true, id = id }
end

function storage.unwrap(desc)
  return registry[desc.id]
end

return storage
