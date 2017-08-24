--[[
  __                 __
_/  |______    ____ |  | __
\   __\__  \  /    \|  |/ /
 |  |  / __ \|   |  \    <
 |__| (____  /___|  /__|_ \
           \/     \/     \/
]]

local gravity = tonumber(minetest.settings:get("movement_gravity")) or 9.81

minetest.register_entity("mvehicles:tank_shoot", {
	physical = true,
	collide_with_objects = true,
	weight = 5,
	collisionbox = {-0.1,-0.1,-0.1, 0.1,0.1,0.1},
	visual ="mesh",
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
		local pos = self.object:get_pos()
		if staticdata == "" then -- initial activate
			self.fuel = 15
			--~ self.object:set_armor_groups({level=5, fleshy=100, explody=250, snappy=50})
		else
			local s = minetest.deserialize(staticdata) or {}
			self.fuel = tonumber(s.fuel) or 0
		end
		self.top = minetest.add_entity(pos, "mvehicles:tank_top", "stay")
		self.top:set_attach(self.object, "", {x=0,y=0,z=0}, {x=0,y=0,z=0})
		self.object:set_acceleration(vector.new(0, -gravity, 0))
		self.can_shoot = true
		self.cannon_direction_horizontal = self.object:get_yaw()
		self.cannon_direction_vertical = -90
	end,

	on_death = function(self, killer)
		self.top:remove()
		minetest.delete_particlespawner(self.exhaust)
		minetest.sound_stop(self.engine_sound)
		tnt.boom(vector.round(self.object:get_pos()), {damage_radius=4,radius=3})
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
		return minetest.serialize({
			fuel = self.fuel,
		})
	end,

	on_rightclick = function(self, clicker)
		if not clicker or not clicker:is_player() then
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

		self.shooting_range = 30


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
		local vel = self.object:get_velocity()
		if vel.y == 0 and (vel.x ~= 0 or vel.z ~= 0) then
			vel = vector.new()
			self.object:set_velocity(vel)
		end
		if not self.driver then
			return
		end
		if self.fuel <= 0 then
			minetest.delete_particlespawner(self.exhaust)
			minetest.sound_stop(self.engine_sound)
			--~ minetest.chat_send_all("no fuel, spawn a new tank")
			return
		--~ else
			--~ minetest.chat_send_all(self.fuel)
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
				anim = {{x=80, y=100}, 30, 0}
				turned = true
			elseif ctrl.right then
				self.cannon_direction_horizontal = self.cannon_direction_horizontal - dtime
				yaw = yaw - dtime
				anim = {{x=60, y=80}, 30, 0}
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
					anim = {{x=0, y=20}, 30, 0}
					self.fuel = self.fuel - 0.1*dtime
					moved = true
				elseif ctrl.down then
					self.object:set_velocity({x=math.cos(yaw+math.pi/2)*-1, y=vel.y, z=math.sin(yaw+math.pi/2)*-1})
					anim = {{x=20, y=40}, 15, 0}
					self.fuel = self.fuel - 0.05*dtime
					moved = true
				else
					moved = false
				end
			end
			self.object:set_animation(unpack(anim))
		end

		if self.top and not ctrl.sneak then
			local dlh = self.driver:get_look_horizontal()
			local dlv = self.driver:get_look_vertical()
			self.cannon_direction_horizontal = dlh
			self.cannon_direction_vertical = math.max(-100,math.min(-60,(-math.deg(dlv)-90)))
			self.top:set_bone_position("top_master", {x=0, y=0, z=0},
					{x=0, y=math.deg(yaw-dlh), z=0})
			self.top:set_bone_position("cannon_barrel", {x=0,y=1.2,z=0},
					{x=self.cannon_direction_vertical,y=0,z=0})
		end

		if ctrl.jump and self.can_shoot then
			local shoot = minetest.add_entity(vector.add(self.object:get_pos(), vector.new(0, 1.2, 0)), "mvehicles:tank_shoot", "stay")
			shoot:set_velocity(vector.add(vel, {
				x=(math.cos(self.cannon_direction_horizontal + math.rad(90)))*((math.sin(math.rad(-self.cannon_direction_vertical)))*self.shooting_range),
				y=(math.cos(math.rad(-self.cannon_direction_vertical)))*self.shooting_range,
				z=(math.sin(self.cannon_direction_horizontal + math.rad(90)))*((math.sin(math.rad(-self.cannon_direction_vertical)))*self.shooting_range)
			}))
			minetest.sound_play("mvehicles_tank_shoot", {
				pos = self.object:get_pos(),
				gain = 0.5,
				max_hear_distance = 32,
			})
			self.can_shoot = false
			minetest.after(3, function()
				self.can_shoot = true
			end)
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
	end,
})
