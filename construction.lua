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
			"size[8,12]"..
			"list[current_player;main;0,8;8,4;]" ..
			"item_image[1,1;2,1;default:mese_crystal]"..
			--"bgcolor[#0000FF;false]"..
			--"background[0,0;0,0;gui_formbg.png;true]"..
			--"pwdfield[4,1;4,1;pass;password]"..
			"field[4,2;2,1;baum;baum;an]"..
			"label[0,0;Constructor]"..
			"vertlabel[0,4;vertical]"..
			"button[0,0;4,2;touch;you can touch this]"..
			"image_button[0,1;1,1;default_dirt.png;dirt;d;flase;true;default_dirt.png^default_grass_side.png]"..
			"button_exit[4,5;2,1;exit;close]"..
			"textlist[2,2.5;2,1;vehicle;tank,truck;tank;true]"..
			"tabheader[-1,4;tabs;tank,truck;tank;true;true]"..
			"dropdown[6,4;2;drop;tank,truck;1]"..
			"checkbox[6,5;check;bla;true]"..
			"scrollbar[6,6;2,0.2;horizontal;scroll;200]"..
			"table[3,5;3,1;tabl;baum,blume;1]"
			)
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
