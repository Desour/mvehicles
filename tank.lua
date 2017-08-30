--[[
  __                 __
_/  |______    ____ |  | __
\   __\__  \  /    \|  |/ /
 |  |  / __ \|   |  \    <
 |__| (____  /___|  /__|_ \
           \/     \/     \/
]]

local registered_turrets = {}
function mvehicles.register_tank_turret(name, def)
	def.bones = def.bones or {}
	def.on_activate = def.on_activate or function(tank)
		tank.turret = minetest.add_entity(tank.object:get_pos(), def.entity, "stay")
		tank.turret:set_attach(tank.object, "", {x=0,y=0,z=0}, {x=0,y=0,z=0})
	end
	registered_turrets[name] = def
end


local gravity = tonumber(minetest.settings:get("movement_gravity")) or 9.81

local function create_id(self)
	for i, obj in pairs(minetest.object_refs) do
		if obj == self.object then
			self.id = i
			break
		end
	end
end

local function create_inv(self, inv_content)
	self.inv = minetest.create_detached_inventory("mvehicles:tank"..self.id, {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			if to_list == "fuel" then
				local stack = inv:get_stack(from_list, from_index)
				stack:set_count(count)
				local output, decremented_input = minetest.get_craft_result({method = "fuel", width = 1, items = {stack}})
				if output.time == 0 then
					return 0
				end
				return math.floor((100-self.fuel)/output.time)
			end
			return count
		end,

		allow_put = function(inv, listname, index, stack, player)
			if listname == "fuel" then
				local output, decremented_input = minetest.get_craft_result({method = "fuel", width = 1, items = {stack}})
				if output.time == 0 then
					return 0
				end
				return math.floor((100-self.fuel)/output.time)
			end
			return stack:get_count()
		end,

		--~ allow_take = func(inv, listname, index, stack, player),
	--~ --  ^ Called when a player wants to take something out of the inventory
	--~ --  ^ Return value: number of items allowed to take
	--~ --  ^ Return value: -1: Allow and don't modify item count in inventory

		on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			if to_list == "fuel" then
				local stack = inv:get_stack(to_list, to_index)
				stack:set_count(count)
				local player_inv = player:get_inventory()
				local pos = player:get_pos()
				local input = {method = "fuel", width = 1, items = {stack}}
				repeat
					local output
					output, input = minetest.get_craft_result(input)
					if output.time == 0 then
						break
					end
					self.fuel = self.fuel + output.time
					local player_inv = player:get_inventory()
					if output.item then
						local lo = player_inv:add_item("main", output.item)
						if not lo:is_empty() then
							minetest.item_drop(lo, player, pos)
						end
					end
					for i = 1, #output.replacements do
						local lo = player_inv:add_item("main", output.replacements[i])
						if not lo:is_empty() then
							minetest.item_drop(lo, player, pos)
						end
					end
				until input.items[1]:is_empty()
				inv:set_stack("fuel", to_index, ItemStack(nil))
				local lo = player_inv:add_item("main", input.items[1])
				if not lo:is_empty() then
					minetest.item_drop(lo, player, pos)
				end
				return
			end
		end,

		on_put = function(inv, listname, index, stack, player)
			if listname == "fuel" then
				local player_inv = player:get_inventory()
				local pos = player:get_pos()
				local input = {method = "fuel", width = 1, items = {stack}}
				repeat
					local output
					output, input = minetest.get_craft_result(input)
					if output.time == 0 then
						break
					end
					self.fuel = self.fuel + output.time
					local player_inv = player:get_inventory()
					if output.item then
						local lo = player_inv:add_item("main", output.item)
						if not lo:is_empty() then
							minetest.item_drop(lo, player, pos)
						end
					end
					for i = 1, #output.replacements do
						local lo = player_inv:add_item("main", output.replacements[i])
						if not lo:is_empty() then
							minetest.item_drop(lo, player, pos)
						end
					end
				until input.items[1]:is_empty()
				inv:set_stack("fuel", index, ItemStack(nil))
				local lo = player_inv:add_item("main", input.items[1])
				if not lo:is_empty() then
					minetest.item_drop(lo, player, pos)
				end
				return
			end
		end,

		--~ on_take = func(inv, listname, index, stack, player),
	--~ --  ^ Called after the actual action has happened, according to what was allowed.
	--~ --  ^ No return value
	})
	self.inv:set_size("fuel", 1)
	self.inv:set_size("ammo", 2*4)
	for listname, list in pairs(inv_content) do
		for i = 1, #list do
			list[i] = ItemStack(list[i])
		end
		self.inv:set_list(listname, list)
	end
end

minetest.register_entity("mvehicles:tank", {
	hp_max = 10,
	physical = true,
	collide_with_objects = true,
	weight = 5,
	collisionbox = {-1.9,-0.99,-1.9, 1.9,0.3,1.9},
	visual = "mesh",
	visual_size = {x=10, y=10},
	mesh = "mvehicles_tank_bottom.b3d",
	textures = {"mvehicles_tank.png"},
	makes_footstep_sound = false,
	automatic_rotate = false,
	stepheight = 1.5,


	on_activate = function(self, staticdata)
		local inv_content
		if staticdata == "" then -- initial activate
			self.fuel = 15
			self.turret_name = "cannon"
			self.owner = ""
			--~ self.object:set_armor_groups({level=5, fleshy=100, explody=250, snappy=50})
		else
			local s = minetest.deserialize(staticdata) or {}
			self.fuel = tonumber(s.fuel) or 15
			self.turret_name = s.turret_name
			self.owner = s.owner or ""
			self.id = s.id
			inv_content = s.inv_content
		end
		if not self.id then
			create_id(self)
		end
		self.inv = minetest.get_inventory({type="detached", name="mvehicles:tank"..self.id})
		if not self.inv then
			create_inv(self, inv_content or {})
		end
		local turret_def = registered_turrets[self.turret_name]
		if not turret_def then
			self.turret_name = "cannon"
			turret_def = registered_turrets[self.turret_name]
		end
		turret_def.on_activate(self)
		self.object:set_acceleration(vector.new(0, -gravity, 0))
		self.cannon_direction_horizontal = self.object:get_yaw()
		self.cannon_direction_vertical = -90
		self.shooting_range = 30
		self.timer = 0
	end,

	on_death = function(self, killer)
		self.turret:remove()
		local pos = self.object:get_pos()
		minetest.delete_particlespawner(self.exhaust)
		minetest.sound_stop(self.engine_sound)
		local inv_lists = self.inv:get_lists()
		for i = 1, #inv_lists do
			local list = inv:get_list(inv_lists[i])
			for k = 1, #list do
				minetest.add_item(pos, list[k])
			end
		end
		tnt.boom(vector.round(pos), {damage_radius=4,radius=3})
		if not self.driver then
			return
		end
		self.driver:set_detach()
		self.driver:set_properties({visual_size = {x=1, y=1}})
		self.driver:set_eye_offset({x=0,y=0,z=0}, {x=0,y=0,z=0})
		default.player_set_animation(self.driver, "stand")
		self.driver:hud_remove(self.fuel_hud_l)
		self.driver:hud_remove(self.fuel_hud_r)
		self.driver:hud_remove(self.shooting_range_hud_l)
		self.driver:hud_remove(self.shooting_range_hud_r)
		default.player_attached[self.driver:get_player_name()] = false
		self.driver:set_hp(0)
	end,

	get_staticdata = function(self)
		local inv_content = {}
		local inv_lists = self.inv:get_lists()
		for i = 1, #inv_lists do
			local listname = inv_lists[i]
			inv_content[listname] = {}
			local list = inv:get_list(listname)
			for k = 1, #list do
				inv_content[listname][i] = list[k]:to_string()
			end
		end
		return minetest.serialize({
			fuel = self.fuel,
			turret_name = self.turret_name,
			owner = self.owner,
			id = self.id,
			inv_content = inv_content,
		})
	end,

	on_rightclick = function(self, clicker)
		if not clicker or not clicker:is_player() then
			return
		end
		if clicker:get_player_control().aux1 then
			minetest.show_formspec(clicker:get_player_name(), "mvehicles:tank"..self.id,
				"size[8,9]"..
				"list[current_player;main;0,5;8,4;]"..
				"list[detached:mvehicles:tank"..self.id..";fuel;0,0;1,1;]"..
				"label[0.2,0.9;fuel]"..
				"list[detached:mvehicles:tank"..self.id..";ammo;5,0.5;2,4;]"..
				"vertlabel[7,1;ammunation]"..
				"listring[current_player;main]"..
				"listring[detached:mvehicles:tank"..self.id..";ammo]"..
				default.gui_bg..
				default.gui_bg_img..
				default.gui_slots)
			return
		end
		if clicker == self.driver then
			self.driver:set_detach()
			self.driver:set_properties({visual_size = {x=1, y=1}})
			self.driver:set_eye_offset({x=0,y=0,z=0}, {x=0,y=0,z=0})
			self.object:set_animation({x=0, y=0}, 0, 0)
			default.player_set_animation(self.driver, "stand")
			minetest.delete_particlespawner(self.exhaust)
			minetest.sound_stop(self.engine_sound)
			self.driver:hud_remove(self.fuel_hud_l)
			self.driver:hud_remove(self.fuel_hud_r)
			self.driver:hud_remove(self.shooting_range_hud_l)
			self.driver:hud_remove(self.shooting_range_hud_r)
			default.player_attached[self.driver:get_player_name()] = false
			self.driver = nil
			return
		elseif self.driver or clicker:get_attach() or
				default.player_attached[clicker:get_player_name()] then
			return
		end
		self.driver = clicker
		default.player_attached[self.driver:get_player_name()] = true
		self.driver:set_attach(self.object, "", {x=0,y=0,z=0}, {x=0,y=0,z=0})
		self.driver:set_properties({visual_size = {x=0.1, y=0.1}})
		self.driver:set_eye_offset({x=0,y=2,z=0}, {x=0,y=10,z=-3})
		default.player_set_animation(self.driver, "sit")

		if self.fuel then
			if self.fuel > 0 then
				minetest.chat_send_all("fuel: "..self.fuel)
			else
				minetest.chat_send_all("no fuel, spawn a new tank")
			end
			self.fuel_hud_1 = self.fuel
			self.fuel_hud_2 = 0
			while self.fuel_hud_1 > 30 do
				self.fuel_hud_1 = self.fuel_hud_1 - 1
				self.fuel_hud_2 = self.fuel_hud_2 + 1
			end
		else
			self.fuel_hud_1 = 0
			self.fuel_hud_2 = 0
		end

		self.fuel_hud_l = self.driver:hud_add({
			hud_elem_type = "statbar", -- see HUD element types
			--  ^ type of HUD element, can be either of "image", "text", "statbar", or "inventory"
			position = {x=0.01, y=0.89},
			--  ^ Left corner position of element
			name = "tankhud",
			scale = {x=2, y=2},
			text = "mvehicles_fuel_can.png",
			number = self.fuel_hud_1,
			item = 3,
			--  ^ Selected item in inventory.  0 for no item selected.
			direction = 3,
			--  ^ Direction: 0: left-right, 1: right-left, 2: top-bottom, 3: bottom-top
			alignment = {x=0, y=0},
			--  ^ See "HUD Element Types"
			offset = {x=0, y=0},
			--  ^ See "HUD Element Types"
			size = { x=50, y=50},
			--  ^ Size of element in pixels
		})
		self.fuel_hud_r = self.driver:hud_add({
			hud_elem_type = "statbar",
			position = {x=0.02, y=0.89},
			name = "tankhud",
			scale = {x=2, y=2},
			text = "mvehicles_fuel_can.png",
			number = self.fuel_hud_2,
			item = 3,
			direction = 3,
			alignment = {x=0, y=0},
			offset = {x=0, y=0},
			size = { x=50, y=50},
		})


		--[[local shooting_range_2 = ((30 - shooting_range_1)^2)^0.5
		local shooting_range_1 = shooting_range_1 - math.abs(shooting_range_1 - 30)
		local shooting_range_2 = shooting_range_2 - (30 - shooting_range_2)]]

		self.shooting_range_hud_l = self.driver:hud_add({
			hud_elem_type = "statbar",
			position = {x=0.06, y=0.89},
			name = "tankhud",
			scale = {x=2, y=2},
			text = "default_mese_crystal.png",
			number = 0,
			item = 3,
			direction = 3,
			alignment = {x=0, y=0},
			offset = {x=0, y=0},
			size = { x=50, y=50},
		})
		self.shooting_range_hud_r = self.driver:hud_add({
			hud_elem_type = "statbar",
			position = {x=0.07, y=0.89},
			name = "tankhud",
			scale = {x=2, y=2},
			text = "default_mese_crystal.png",
			number = 0,
			item = 3,
			direction = 3,
			alignment = {x=0, y=0},
			offset = {x=0, y=0},
			size = { x=50, y=50},
		})

		self.exhaust = minetest.add_particlespawner({
			amount = 10,
			time = 0,
			minpos = {x=-0.5,y=1.25,z=-1.2},
			maxpos = {x=-0.5,y=1.25,z=-1.2},
			minvel = {x=-0.1, y=1, z=-0.1},
			maxvel = {x=0.1, y=1.5, z=0.1},
			minacc = {x=0, y=0, z=0},
			maxacc = {x=0, y=0, z=0},
			minexptime = 1,
			maxexptime = 2,
			minsize = 1,
			maxsize = 3,
			collisiondetection = true,
			collision_removal = false,
			attached = self.object,
			vertical = false,
			texture = "tnt_smoke.png",
		})

		self.engine_sound = minetest.sound_play("mvehicles_engine", {
			object = self.object,
			gain = 0.5,
			max_hear_distance = 32,
			loop = true,
		})
	end,


	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		local vel = self.object:get_velocity()
		if vel.y == 0 and (vel.x ~= 0 or vel.z ~= 0) then
			vel = vector.new()
			self.object:set_velocity(vel)
		end
		if not self.driver or self.fuel <= 0 then
			return
		end
		self.fuel = self.fuel - 0.001 * dtime
		local yaw = self.object:get_yaw()
		local ctrl = self.driver:get_player_control()
		local turned
		local moved
		if vel.y == 0 then
			local anim
			if ctrl.left then
				yaw = yaw + dtime
				self.cannon_direction_horizontal = self.cannon_direction_horizontal + dtime
				anim = {{x=80, y=99}, 30, 0}
				turned = true
			elseif ctrl.right then
				self.cannon_direction_horizontal = self.cannon_direction_horizontal - dtime
				yaw = yaw - dtime
				anim = {{x=60, y=79}, 30, 0}
				turned = true
			else
				anim = {{x=0, y=0}, 0, 0}
				turned = false
			end
			if turned then
				self.object:set_yaw((yaw+2*math.pi)%(2*math.pi))
				self.fuel = self.fuel - 0.01*dtime
			else
				if ctrl.up then
					self.object:set_velocity({x=math.cos(yaw+math.pi/2)*2, y=vel.y, z=math.sin(yaw+math.pi/2)*2})
					anim = {{x=0, y=19}, 30, 0}
					self.fuel = self.fuel - 0.1*dtime
					moved = true
				elseif ctrl.down then
					self.object:set_velocity({x=math.cos(yaw+math.pi/2)*-1, y=vel.y, z=math.sin(yaw+math.pi/2)*-1})
					anim = {{x=20, y=39}, 15, 0}
					self.fuel = self.fuel - 0.05*dtime
					moved = true
				else
					moved = false
				end
			end
			self.object:set_animation(unpack(anim))
		end

		local turret_def = registered_turrets[self.turret_name]
		if self.turret and not (ctrl.sneak or self.static_turret) then
			local dlh = self.driver:get_look_horizontal()
			local dlv = self.driver:get_look_vertical()
			self.cannon_direction_horizontal = dlh
			self.cannon_direction_vertical = math.max(-100,math.min(-60,(-math.deg(dlv)-90)))
			if turret_def.bones[1] then
				self.turret:set_bone_position(turret_def.bones[1], {x=0, y=0, z=0},
						{x=0, y=math.deg(yaw-dlh), z=0})
			end
			if turret_def.bones[2] then
				self.turret:set_bone_position(turret_def.bones[2], {x=0,y=1.2,z=0},
						{x=self.cannon_direction_vertical,y=0,z=0})
			end
		end

		local shooted = false
		if ctrl.jump and (not self.last_shoot_time or
				self.timer >= self.last_shoot_time + turret_def.shoot_cooldown) then
			shooted = true
			turret_def.shoot(self, dtime)
			self.last_shoot_time = self.timer
		end

		if turret_def.on_step then
			turret_def.on_step(self, dtime, shooted)
		end

		if self.shooting_range then
			self.shooting_range_hud_1 = self.shooting_range
			self.shooting_range_hud_2 = 0
			while self.shooting_range_hud_1 > 30 do
				self.shooting_range_hud_1 = self.shooting_range_hud_1 - 1
				self.shooting_range_hud_2 = self.shooting_range_hud_2 + 1
			end
		else
			self.shooting_range_hud_1 = 0
			self.shooting_range_hud_2 = 0
		end
		self.driver:hud_change(self.shooting_range_hud_l, "number", self.shooting_range_hud_1)
		self.driver:hud_change(self.shooting_range_hud_r, "number", self.shooting_range_hud_2)

		if self.fuel <= 0 then
			self.fuel = 0
			self.object:set_animation({x=0, y=0}, 0, 0)
			minetest.delete_particlespawner(self.exhaust)
			minetest.sound_stop(self.engine_sound)
			minetest.chat_send_all("no fuel, spawn a new tank")
		end
	end,
})



minetest.register_entity("mvehicles:tank_shoot", {
	physical = true,
	collide_with_objects = true,
	weight = 5,
	collisionbox = {-0.1,-0.1,-0.1, 0.1,0.1,0.1},
	visual = "mesh",
	visual_size = {x=5, y=5},
	mesh = "mvehicles_tank_shoot.b3d",
	textures = {"mvehicles_tank_shoot.png"},
	automatic_rotate = false,
	automatic_face_movement_dir = 90.0,
--  ^ automatically set yaw to movement direction; offset in degrees; false to disable
	automatic_face_movement_max_rotation_per_sec = -1,
--  ^ limit automatic rotation to this value in degrees per second. values < 0 no limit

	on_activate = function(self, staticdata)
		if staticdata ~= "stay" then
			self.object:remove()
			return
		end
		self.object:set_acceleration(vector.new(0, -gravity, 0))
	end,

	on_step = function(self, dtime)
		local vel = self.object:get_velocity()
		if self.oldvel and
				((self.oldvel.x ~= 0 and vel.x == 0) or
				(self.oldvel.y ~= 0 and vel.y == 0) or
				(self.oldvel.z ~= 0 and vel.z == 0)) then
			tnt.boom(vector.round(self.object:get_pos()), {damage_radius=3,radius=2})
			self.object:remove()
			return
		end

		local rot = -math.deg(math.atan(vel.y/(vel.x^2+vel.z^2)^0.5))
		self.object:set_animation({x=rot+90, y=rot+90}, 0, 0)

		self.oldvel = vel
	end
})

minetest.register_entity("mvehicles:tank_top", {
	physical = false,
	weight = 5,
	collisionbox = {0,0,0, 0,0,0},
	visual = "mesh",
	visual_size = {x=1, y=1},
	mesh = "mvehicles_tank_top.b3d",
	textures = {"mvehicles_tank.png"},
	on_activate = function(self, staticdata, dtime_s)
		if staticdata ~= "stay" then
			self.object:remove()
		end
	end,
})

mvehicles.register_tank_turret("cannon", {
	entity = "mvehicles:tank_top",
	shoot_cooldown = 3,
	bones = {"top_master", "cannon_barrel"},
	shoot = function(tank)
		local vel = tank.object:get_velocity()
		local shoot = minetest.add_entity(vector.add(tank.object:get_pos(), vector.new(0, 1.2, 0)), "mvehicles:tank_shoot", "stay")
		shoot:set_velocity(vector.add(vel, {
			x=math.cos(tank.cannon_direction_horizontal + math.rad(90))*math.sin(math.rad(-tank.cannon_direction_vertical))*tank.shooting_range,
			y=math.cos(math.rad(-tank.cannon_direction_vertical))*tank.shooting_range,
			z=math.sin(tank.cannon_direction_horizontal + math.rad(90))*math.sin(math.rad(-tank.cannon_direction_vertical))*tank.shooting_range
		}))
		minetest.sound_play("mvehicles_tank_shoot", {
			pos = tank.object:get_pos(),
			gain = 0.5,
			max_hear_distance = 32,
		})
	end,
})

if minetest.get_modpath("carts") then
	mvehicles.register_tank_turret("railgun", {
		entity = "mvehicles:tank_top",
		shoot_cooldown = 0,
		bones = {"top_master", "cannon_barrel"},
		shoot = function(tank, dtime)
			if not tank.railgun_load_start then
				tank.static_turret = true
				tank.railgun_load_start = tank.timer
			elseif math.floor(tank.railgun_load_start-tank.timer) < math.floor(tank.railgun_load_start+dtime-tank.timer) then
				minetest.chat_send_player(tank.driver:get_player_name(), tostring(math.floor(tank.railgun_load_start-tank.timer+6)))
			end
		end,
		on_step = function(tank, dtime, shooting)
			if not shooting and tank.railgun_load_start then
				if tank.timer >= tank.railgun_load_start + 5 then
					local vel = tank.object:get_velocity()
					local pos = tank.object:get_pos()
					local rail = minetest.add_item(pos, ItemStack("carts:rail"))
					rail:set_velocity(vector.add(vel, {
						x=math.cos(tank.cannon_direction_horizontal + math.rad(90))*math.sin(math.rad(-tank.cannon_direction_vertical))*tank.shooting_range*2,
						y=math.cos(math.rad(-tank.cannon_direction_vertical))*tank.shooting_range*2,
						z=math.sin(tank.cannon_direction_horizontal + math.rad(90))*math.sin(math.rad(-tank.cannon_direction_vertical))*tank.shooting_range*2
					}))
				end
				tank.static_turret = false
				tank.railgun_load_start = nil
			end
		end,
	})
end

mvehicles.register_tank_turret("drill", {
	entity = "mvehicles:tank_top",
	shoot_cooldown = 0.5,
	shoot = function(tank)
		local dir = minetest.yaw_to_dir(tank.object:get_yaw())
		local pos = tank.object:get_pos()
		pos = vector.add(pos, vector.multiply(dir, 2))
		local less = dir.x > dir.z and "z" or "x"
		for y = 0, 2 do
			for i = -1.5, 1.5 do
				local pos = vector.new(pos)
				pos.y = pos.y + y
				pos[less] = pos[less] + i
				local drops = minetest.get_node_drops(minetest.get_node(pos).name, "")
				minetest.dig_node(pos)
				for i = 1, #drops do
					local leftover = tank.inv:add_item("ammo", drops[i])
					if not leftover:is_empty() then
						minetest.item_drop(leftover, tank.driver, pos)
					end
				end
			end
		end
	end,
})
