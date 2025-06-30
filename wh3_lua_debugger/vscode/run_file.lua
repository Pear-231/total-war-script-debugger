-- run_file.lua
-- Usage: just press F5 in VSCode on any .lua file

-- 1) preload your cm stub
require("wh3_lua_debugger.vscode.campaign_manager_rpc")

-- 2) grab the target path from the RUN_FILE env var
local path = os.getenv("RUN_FILE")
assert(path, "RUN_FILE environment variable not set")

-- 3) load & run that file
local fn, err = loadfile(path)
assert(fn, err)
return fn()
