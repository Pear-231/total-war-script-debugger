require("wh3_lua_debugger.vscode.scripting_class_proxies")

out = print

local path = os.getenv("DEBUG")
local fn, err = loadfile(path)
assert(fn, err)
return fn()
