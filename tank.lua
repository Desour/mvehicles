--[[
  __                 __
_/  |______    ____ |  | __
\   __\__  \  /    \|  |/ /
 |  |  / __ \|   |  \    <
 |__| (____  /___|  /__|_ \
           \/     \/     \/
]]

minetest.register_entity("mvehicles:tank_shoot", {
	hp_max = 1,
	physical = true,
	collide_with_objects = true,
	weight = 5,
	collisionbox = {-0.1,-0.1,-0.1, 0.1,0.1,0.1},
	visual ="mesh",	--"cube"/"sprite"/"upright_sprite"/"mesh"/"wielditem",
	visual_size = {x=5, y=5},
	mesh = "mvehicles_tank_shoot.b3d",
	textures = {"mvehicles_tank_shoot.png"},
	colors = {},
	spritediv = {x=1, y=1},
	initial_sprite_basepos = {x=0, y=0},
	is_visible = true,
	makes_footstep_sound = false,
	automatic_rotate = false,
	automatic_face_movement_dir = 90.0,
--  ^ automatically set yaw to movement direction; offset in degrees; false to disable
	automatic_face_movement_max_rotation_per_sec = -1,
--  ^ limit automatic rotation to this value in degrees per second. values < 0 no limit

	on_activate = function(self, staticdata)
		if staticdata ~= "" then
			self.object:remove()
		end
		self.object:setacceleration({x=0,y=-5,z=0})
	end,

	get_staticdata = function(self)
		return "activated"
	end,

	on_step = function(self, dtime)
		local acc = self.object:getacceleration()
		local vel = self.object:getvelocity()
		local pos = self.object:getpos()
		--[[if self.oldpos and self.oldvel and self.oldacc then
			minetest.chat_send_all("oldacc = " .. dump(self.oldacc))
			minetest.chat_send_all("oldvel = " .. dump(self.oldvel))
			minetest.chat_send_all(dump(vector.add(self.oldvel, {
				x=dtime * self.oldacc.x,
				y=dtime * self.oldacc.y,
				z=dtime * self.oldacc.z})))
			--~ if not vel <=
					vector.add(self.oldvel, {
						x=math.ceil(dtime * self.oldacc.x),
						y=math.ceil(dtime * self.oldacc.y),
						z=math.ceil(dtime * self.oldacc.z)}) then
			if math.floor(vel.x * 10) / 10 ~=
					math.floor(dtime * self.oldacc.x * 10) / 10 or
					math.floor(vel.y * 10) / 10 ~=
					math.floor(dtime * self.oldacc.y * 10) / 10 or
					math.floor(vel.y * 10) / 10 ~=
					math.floor(dtime * self.oldacc.y * 10) / 10 then
				minetest.chat_send_all("explosion")
			end
		else
			minetest.chat_send_all("no oldpos and oldvel and oldacc")
		end]]

		if self.oldvel then
			if ((self.oldvel.x ~= 0 and vel.x == 0)
			or (self.oldvel.y ~= 0 and vel.y == 0)
			or (self.oldvel.z ~= 0 and vel.z == 0))
			and (not self.explosion) then
				self.explosion = true
			end
			if self.explosion == true then
				tnt.boom(vector.round(pos),
						{damage_radius=3,radius=2, ignore_protection=true})
				self.object:remove()
			end
		end

		local rot = -math.deg(math.atan(vel.y/(vel.x^2+vel.z^2)^0.5))
		self.object:set_animation({x=rot+90, y=rot+90}, 0, 0)

		self.oldpos = pos
		self.oldvel = vel
		self.oldacc = acc
	end
})

minetest.register_entity("mvehicles:tank_exhauster", {
	hp_max = 1,
	physical = false,
	weight = 5,
	collisionbox = {0,0,0, 0,0,0},
	visual = "mesh",
	visual_size = {x=1, y=1},
	mesh = "mvehicles_tank_exhauster.b3d",
	textures = {"mvehicles_tank.png"},
	colors = {},
	spritediv = {x=1, y=1},
	initial_sprite_basepos = {x=0, y=0},
	is_visible = true,
	makes_footstep_sound = false,
	automatic_rotate = false,

	on_activate = function(self, staticdata, dtime_s)
		if string.sub(staticdata, 1, 1) ~= "m" then
			local pos = self.object:getpos()
			minetest.chat_send_all("’mvehicles:tank_exhauster’ without ID"..
				" was found at ("..pos.x..", "..pos.y..", "..pos.z.."), removing...")
			self.object:remove()
			return
		end
		self.id = staticdata
		--~ if os.time() ~= tonumber(string.sub(self.id, 22, string.find(self.id, "p")-2)) then
			--~ if not self.object:get_attach() then
				--~ self.object:remove()
			--~ end
		--~ end
	end,

	get_staticdata = function(self)
		return self.id
	end,

	on_step = function(self)
		if not self.ok then
			if self.object:get_attach() then
				self.ok = true
			else
				self.object:remove()
			end
		end
	end
})




minetest.register_entity("mvehicles:tank_top", {
	hp_max = 1,
	physical = false,
	weight = 5,
	collisionbox = {0,0,0, 0,0,0},
	visual = "mesh",
	visual_size = {x=1, y=1},
	mesh = "mvehicles_tank_top.b3d",
	textures = {"mvehicles_tank.png"},
	colors = {},
	spritediv = {x=1, y=1},
	initial_sprite_basepos = {x=0, y=0},
	is_visible = true,
	makes_footstep_sound = false,
	automatic_rotate = false,

	on_activate = function(self, staticdata, dtime_s)
		if string.sub(staticdata, 1, 1) ~= "m" then
			local pos = self.object:getpos()
			minetest.chat_send_all("’mvehicles:tank_top’ without ID"..
				" was found at ("..pos.x..", "..pos.y..", "..pos.z.."), removing...")
			self.object:remove()
			return
		end
		self.id = staticdata
		--~ if os.time() ~= tonumber(string.sub(self.id, 22, string.find(self.id, "p")-2)) then
			--~ if not self.object:get_attach() then
				--~ self.object:remove()
			--~ end
		--~ end
	end,

	get_staticdata = function(self)
		return self.id
	end,

	on_step = function(self)
		if not self.ok then
			if self.object:get_attach() then
				self.ok = true
			else
				self.object:remove()
			end
		end
	end
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
	textures = {
		"mvehicles_tank.png"--[[,
		"mvehicles_decal_1.png",
		"mvehicles_decal_2.png",
		"mvehicles_decal_3.png",
		"mvehicles_decal_4.png",
		"mvehicles_decal_5.png"]]
		},
	colors = {},
	spritediv = {x=1, y=1},
	initial_sprite_basepos = {x=0, y=0},
	is_visible = true,
	makes_footstep_sound = false,
	automatic_rotate = false,
	stepheight = 1.5,


	on_activate = function(self, staticdata)
		local pos = self.object:getpos()
		if staticdata == "" then -- initial activate
			self.id = "mvehicles:tank\ntime:\n"..os.time().."\npos:\n"..dump(pos)
			self.fuel = 15
			--~ self.object:set_armor_groups({level=5, fleshy=100, explody=250, snappy=50})
		else
			local s = minetest.deserialize(staticdata)
			self.id = s.id
			self.fuel = s.fuel
			local objs = minetest.get_objects_inside_radius(pos, 1)
			for _,obj in pairs(objs) do
				minetest.chat_send_all("bla0")
				local luaent
				if not obj:is_player() then
					luaent = obj:get_luaentity()
				end
				if luaent and luaent.id == self.id then
					minetest.chat_send_all("bla1")
					minetest.chat_send_all(dump(luaent)) -- here to see: name is missing. https://github.com/minetest/minetest/blob/master/doc/lua_api.txt#L3526
					if not self.top and luaent.name == "mvehicles:tank_top" then
						minetest.chat_send_all("bla2t")
						self.top = obj
					elseif not self.exhauster and luaent.name == "mvehicles:tank_exhauster" then
						minetest.chat_send_all("bla2e")
						self.exhauster = obj
					elseif self.exhauster and self.top then
						break
					end
				end
			end
		end
		if not self.top then
			self.top = minetest.add_entity(pos, "mvehicles:tank_top", self.id)
			minetest.chat_send_all("new top")
		end
		if not self.exhauster then
			self.exhauster = minetest.add_entity(pos, "mvehicles:tank_exhauster", self.id)
			minetest.chat_send_all("new exhauster")
		end
		self.exhauster:set_attach(self.object, "", {x=-0.7,y=0.8,z=-1.3}, {x=0,y=0,z=0})
		self.top:set_attach(self.object, "", {x=0,y=0,z=0}, {x=0,y=0,z=0})
		self.object:setacceleration({
			x = 0,
			y = -tonumber(minetest.setting_get("movement_gravity")),
			z = 0})
		self.shootable = true
	end,


	get_staticdata = function(self)
		return minetest.serialize({
			fuel = self.fuel,
			--[[top=self.top,
			exhauster=self.exhauster,]]
			id = self.id})
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
			default.player_set_animation(self.driver, stand)
			minetest.delete_particlespawner(self.exhaust)
			minetest.sound_stop(self.engine_sound)
			self.driver:hud_remove(self.fuel_hud_l)
			self.driver:hud_remove(self.fuel_hud_r)
			self.driver:hud_remove(self.shooting_range_hud_l)
			self.driver:hud_remove(self.shooting_range_hud_r)
			default.player_attached[self.driver:get_player_name()] = false
			self.driver = nil
		elseif not self.driver and not clicker:get_attach() then
			self.driver = clicker
			default.player_attached[self.driver:get_player_name()] = true
			self.driver:set_attach(self.object, "", {x=0,y=0,z=0}, {x=0,y=0,z=0})
			self.driver:set_properties({visual_size = {x=0.1, y=0.1}})
			self.driver:set_eye_offset({x=0,y=2,z=0}, {x=0,y=10,z=-3})
			default.player_set_animation(self.driver, sit)

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

			self.shooting_range = 10


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
				minpos = {x=0, y=0.5, z=0},
				maxpos = {x=0, y=0.5, z=0},
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
				attached = self.exhauster,
				vertical = false,
				texture = "tnt_smoke.png",
			})

			self.engine_sound = minetest.sound_play("mvehicles_engine", {
				object = self.object,
				gain = 0.5,
				max_hear_distance = 32,
				loop = true,
			})
		end
	end,


	on_step = function(self, dtime)
		local vel = self.object:getvelocity()
		if vel.y == 0 and (vel.x ~= 0 or vel.z ~= 0) then
			self.object:setvelocity({x=0, y=0, z=0})
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
		self.fuel = self.fuel - 0.001*dtime
		local yaw = self.object:getyaw()
		local ctrl = self.driver:get_player_control()
		local turned
		local moved
		if vel.y == 0 then
			if ctrl.left then
				yaw = yaw + dtime
				self.object:set_animation({x=80, y=100}, 30, 0)
				turned = true
			elseif ctrl.right then
				yaw = yaw - dtime
				self.object:set_animation({x=60, y=80}, 30, 0)
				turned = true
			else
				self.object:set_animation({x=0, y=0}, 0, 0)
				turned = false
			end
			if turned then
				self.object:setyaw((yaw+2*math.pi)%(2*math.pi))
				self.fuel = self.fuel - 0.01*dtime
			else
				if ctrl.up --[[and not turned]] then
					self.object:setvelocity({x=math.cos(yaw+math.pi/2)*2, y=vel.y, z=math.sin(yaw+math.pi/2)*2})
					self.object:set_animation({x=0, y=20}, 30, 0)
					self.fuel = self.fuel - 0.1*dtime
					moved = true
				elseif ctrl.down --[[and not turned]] then
					self.object:setvelocity({x=math.cos(yaw+math.pi/2)*-1, y=vel.y, z=math.sin(yaw+math.pi/2)*-1})
					self.object:set_animation({x=20, y=40}, 15, 0)
					self.fuel = self.fuel - 0.05*dtime
					moved = true
				else
					moved = false
				end
				if ctrl.jump --[[and vel.y == 0]] --[[and not turned]] then
					if self.shootable then
						local shoot = minetest.add_entity(vector.add(self.object:getpos(), {x=0,y=1.2,z=0}), "mvehicles:tank_shoot")
						shoot:setvelocity(vector.add(vel,{
							x=(math.cos(self.cannon_direction_horizontal + math.rad(90)))*((math.sin(math.rad(-self.cannon_direction_vertical)))*self.shooting_range),
							y=(math.cos(math.rad(-self.cannon_direction_vertical)))*self.shooting_range,
							z=(math.sin(self.cannon_direction_horizontal + math.rad(90)))*((math.sin(math.rad(-self.cannon_direction_vertical)))*self.shooting_range)
						}))
						minetest.sound_play("mvehicles_tank_shoot", {
							pos = self.object:getpos(),
							gain = 0.5,
							max_hear_distance = 32,
						})
						self.shootable = false
						minetest.after(3,
								function(self)
									self.shootable = true
								end,
								self)
					end
				end
			end
		end

		if self.top and not ctrl.sneak then
			local dlh = self.driver:get_look_horizontal()
			local dlv = self.driver:get_look_vertical()
			self.cannon_direction_horizontal = dlh
			self.top:set_bone_position("top_master", {x=0, y=0, z=0},
					{x=0, y=math.deg(yaw-dlh), z=0})
			self.cannon_direction_vertical =
					math.max(-100,math.min(-60,(-math.deg(dlv)-90)))
			self.top:set_bone_position("cannon_barrel", {x=0,y=1.2,z=0},
					{x=self.cannon_direction_vertical,y=0,z=0})
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
	end
})
