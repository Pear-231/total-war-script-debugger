require("wh3_lua_debugger.vscode.campaign_manager_rpc")

local path = os.getenv("DEBUG")
local fn, err = loadfile(path)
assert(fn, err)
return fn()
