
local modname = minetest.get_current_modname()
assert(modname == "mvehicles", "mod can't be renamed")
local path = minetest.get_modpath(modname) .. "/"

mvehicles = {}

dofile(path.."tank.lua")
dofile(path.."truck.lua")
dofile(path.."construction.lua")
