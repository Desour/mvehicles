--[[
                              __                        __  .__
  ____  ____   ____   _______/  |________ __ __   _____/  |_|__| ____   ____
_/ ___\/  _ \ /    \ /  ___/\   __\_  __ \  |  \_/ ___\   __\  |/  _ \ /    \
\  \__(  <_> )   |  \\___ \  |  |  |  | \/  |  /\  \___|  | |  (  <_> )   |  \
 \___  >____/|___|  /____  > |__|  |__|  |____/  \___  >__| |__|\____/|___|  /
     \/           \/     \/                          \/                    \/
--]]

minetest.register_node("mvehicles:constructor", {
	description = "constructor",
	tiles = {"mvehicles_hull.png^default_mese_crystal.png"},
	groups = {cracky=2, level=2},
	sounds = default.node_sound_stone_defaults(),

	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local p = clicker:get_player_name()
		minetest.show_formspec(p, "mvehicles:constructor_formspec",
			"size[4,3]" ..
			"label[0,0;Hello, " .. p .. "!\nThis a not usable node.]" ..
			"field[1,1.5;3,1;name;Name;]" ..
			"button_exit[1,2;2,1;exit;Exit]")
	end
})

minetest.register_node("mvehicles:hull", {
	description = "hull",
	tiles = {"mvehicles_hull.png"},
	groups = {cracky=2, level=2},
	sounds = default.node_sound_stone_defaults(),
})

stairs.register_slab(
	"hull",
	"mvehicles:hull",
	{cracky=2, level=2},
	{"mvehicles_hull.png"},
	"Pine Wood Slab",
	default.node_sound_stone_defaults()
)

minetest.register_node("mvehicles:tank_tracks", {
	description = "tank tracks",
	tiles = {"mvehicles_tank_tracks.png","mvehicles_tank_tracks.png","mvehicles_wheel.png",
		"mvehicles_wheel.png","mvehicles_tank_tracks.png^[transformFY","mvehicles_tank_tracks.png"},
	-- +Y, -Y, +X, -X, +Z, -Z
	groups = {cracky=2, level=2},
	paramtype2 = "facedir",
	sounds = default.node_sound_stone_defaults()
})

minetest.register_craftitem("mvehicles:steel_plate", {
	description = "steel plate",
	inventory_image = "mvehicles_hull.png",
	groups = {steelplate = 1},
})

minetest.register_craft({
	output = "mvehicles:steel_plate 4",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", "dye:dark_green"},
		{"default:steel_ingot", "default:steel_ingot", ""},
	}
})

minetest.register_craft({
	output = "mvehicles:hull 5",
	recipe = {
		{"mvehicles:steel_plate", "mvehicles:steel_plate", "mvehicles:steel_plate"},
		{"", "default:steelblock", ""},
		{"mvehicles:steel_plate", "mvehicles:steel_plate", "mvehicles:steel_plate"},
	}
})
