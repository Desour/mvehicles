--[[
                    .__    .__       .__
  ________  __ ____ |  |__ |__| ____ |  |   ____   ______
 /     \  \/ // __ \|  |  \|  |/ ___\|  | _/ __ \ /  ___/
|  Y Y  \   /\  ___/|   Y  \  \  \___|  |_\  ___/ \___ \
|__|_|  /\_/  \___  >___|  /__|\___  >____/\___  >____  >
      \/          \/     \/        \/          \/     \/
]]

local load_time_start = os.clock()

local modname = minetest.get_current_modname()

local path = minetest.get_modpath(modname).. DIR_DELIM

dofile(path.."tank.lua")
dofile(path.."truck.lua")
dofile(path.."construction.lua")


local time = math.floor(tonumber(os.clock()-load_time_start)*100+0.5)/100
local msg = "["..modname.."] loaded after ca. "..time
if time > 0.05 then
	print(msg)
else
	minetest.log("info", msg)
end
