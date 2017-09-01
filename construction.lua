--[[
                              __                        __  .__
  ____  ____   ____   _______/  |________ __ __   _____/  |_|__| ____   ____
_/ ___\/  _ \ /    \ /  ___/\   __\_  __ \  |  \_/ ___\   __\  |/  _ \ /    \
\  \__(  <_> )   |  \\___ \  |  |  |  | \/  |  /\  \___|  | |  (  <_> )   |  \
 \___  >____/|___|  /____  > |__|  |__|  |____/  \___  >__| |__|\____/|___|  /
     \/           \/     \/                          \/                    \/
--‫]]

minetest.register_node("mvehicles:constructor", {
	description = "constructor",
	tiles = {"mvehicles_hull.png^default_mese_crystal.png"},
	groups = {cracky=2, level=2},
	sounds = default.node_sound_stone_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec",
			"size[8,4]"..
			--~ "list[context;turret;3.5,2;1,1;]"..
			--~ "list[context;base;3.5,3;1,1;]"..
			--~ "list[current_player;main;0,5;8,4;]"..
			"button[4,2;3,1;build;Build Tank]"..
			"button[4,3;3,1;truck;Build Truck]"..
			"field[1,1;5,1;turret_name;Turret;cannon]"..
			"field_close_on_enter[turret_name;false]"..
			default.gui_bg..
			default.gui_bg_img..
			default.gui_slots)
		--~ local inv = meta:get_inventory()
		--~ inv:set_size("base", 1)
		--~ inv:set_size("turret", 1)
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		if fields.build then
			pos.y = pos.y + 1.8
			minetest.add_entity(pos, "mvehicles:tank", minetest.serialize({
				fuel = 15,
				turret_name = fields.turret_name,
				owner = sender and sender:is_player() and sender:get_player_name() or "",
			}))
		elseif fields.truck then
			pos.y = pos.y + 1.8
			minetest.add_entity(pos, "mvehicles:truck")
		end
	end,
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
