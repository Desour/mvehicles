minetest.register_entity(
	"mvehicles:tank_shoot",
	{
		hp_max = 1,
		physical = true,
		collide_with_objects = true,
		weight = 5,
		collisionbox = {-0.1,-0.1,-0.1, 0.1,0.1,0.1},
		visual ="sprite",	--"cube"/"sprite"/"upright_sprite"/"mesh"/"wielditem",
		visual_size = {x=0.5, y=0.5},
		textures = {"heart.png"},
		colors = {},
		spritediv = {x=1, y=1},
		initial_sprite_basepos = {x=0, y=0},
		is_visible = true,
		makes_footstep_sound = false,
		automatic_rotate = false,

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
			--[[if self.oldpos and self.oldvel and self.oldacc then
				minetest.chat_send_all("oldacc = " .. minetest.serialize(self.oldacc))
				minetest.chat_send_all("oldvel = " .. minetest.serialize(self.oldvel))
				minetest.chat_send_all(minetest.serialize(vector.add(self.oldvel, {x=dtime * self.oldacc.x, y=dtime * self.oldacc.y, z=dtime * self.oldacc.z})))
				--if not self.object:getvelocity() <= vector.add(self.oldvel, {x=math.ceil(dtime * self.oldacc.x), y=math.ceil(dtime * self.oldacc.y), z=math.ceil(dtime * self.oldacc.z)}) then
				if math.floor(self.object:getvelocity().x * 10) / 10 ~= math.floor(dtime * self.oldacc.x * 10) / 10 or math.floor(self.object:getvelocity().y * 10) / 10 ~= math.floor(dtime * self.oldacc.y * 10) / 10 or math.floor(self.object:getvelocity().y * 10) / 10 ~= math.floor(dtime * self.oldacc.y * 10) / 10 then
					minetest.chat_send_all("explosion")
				end
			else
				minetest.chat_send_all("no oldpos and oldvel and oldacc")
			end]]

			if self.oldvel then
				if ((self.oldvel.x ~= 0 and self.object:getvelocity().x == 0)
				or (self.oldvel.y ~= 0 and self.object:getvelocity().y == 0)
				or (self.oldvel.z ~= 0 and self.object:getvelocity().z == 0))
				and (not self.explosion) then
					self.explosion = true
				end
				if self.explosion == true then
					--minetest.chat_send_all("explosion")
					tnt.boom(self.object:getpos(),{damage_radius=3,radius=3,ignore_protection=true})
					self.object:remove()
				end
			end

			self.oldpos = self.object:getpos()
			self.oldvel = self.object:getvelocity()
			self.oldacc = self.object:getacceleration()
		end
	}
)

minetest.register_entity(
	"mvehicles:tank_exhauster",
	{
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

		on_step = function(self, staticdata)
			if staticdata ~= "" then
				if not self.object:get_attach() then
					self.object:remove()
				end
			end
		end,

		get_staticdata = function(self)
			return "activated"
		end
	}
)




minetest.register_entity(
	"mvehicles:tank_top",
	{
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

		--[[on_rightclick = function(self, clicker)
			self.object:remove()
		end,]]

		on_step = function(self, staticdata)
			if staticdata ~= "" then
				if not self.object:get_attach() then
					self.object:remove()
				end
			end
		end,

		get_staticdata = function(self)
			return "activated"
		end
	}
)



minetest.register_entity(
	"mvehicles:tank",
	{
		hp_max = 10,
		physical = true,
		weight = 5,
		collisionbox = {-1.9,-0.99,-1.9, 1.9,1,1.9},
		visual = "mesh",
		visual_size = {x=10, y=10},
		mesh = "mvehicles_tank_bottom.b3d",
		textures = {"mvehicles_tank.png"},
		colors = {},
		spritediv = {x=1, y=1},
		initial_sprite_basepos = {x=0, y=0},
		is_visible = true,
		makes_footstep_sound = false,
		automatic_rotate = false,
		stepheight = 1.5,


		on_activate = function(self, staticdata)
			--self.object:set_armor_groups({level=5, fleshy=100, explody=250, snappy=50})
			self.top = minetest.add_entity(self.object:getpos(), "mvehicles:tank_top")
			self.exhauster = minetest.add_entity(self.object:getpos(), "mvehicles:tank_exhauster")
			if self.top then
				self.top:set_attach(self.object, "", {x=0,y=0,z=0}, {x=0,y=0,z=0})
			end
			if self.exhauster then
				self.exhauster:set_attach(self.object, "", {x=-0.7,y=0.8,z=-1.3}, {x=0,y=0,z=0})
			end

			self.object:setacceleration({x=0, y=-10, z=0})

			self.shootable = true

			--a try to fix the disappearing of the player after the death of the tank
			--[[if staticdata then
				if self.driver then
					if self.driver:get_attach() then
						self.driver:set_detach()
						self.driver:set_properties({visual_size = {x=1, y=1}})
					end
				end
			end]]
		end,


		get_staticdata = function(self)
			return "activated"
		end,

		--on_punch = function(self, puncher)
			--some old relict from the past
			--[[self.object:setvelocity({x=0, y=0, z=1})
			--self.object:setacceleration({x=0, y=-10, z=1})
			self.object:set_animation({x=0, y=20}, 30, 0)
			--os.execute("sleep 1")]]
		--end,


		on_rightclick = function(self, clicker)
			if not clicker or not clicker:is_player() then
				return
			end
			self.driver = clicker
			if clicker:get_attach() then
				self.driver:set_detach()
				self.driver:set_properties({visual_size = {x=1, y=1}})
				self.driver:set_eye_offset({x=0,y=0,z=0}, {x=0,y=0,z=0})
				self.object:set_animation({x=0, y=0}, 0, 0)
				minetest.delete_particlespawner(self.exhaust)
				minetest.sound_stop(self.engine_sound)
				self.driver:hud_remove(self.fuel_hud_l)
				self.driver:hud_remove(self.fuel_hud_r)
				self.driver:hud_remove(self.shooting_range_hud_l)
				self.driver:hud_remove(self.shooting_range_hud_r)
				self.driver = nil
			else
				self.driver:set_attach(self.object, "", {x=0,y=0,z=0}, {x=0,y=0,z=0})
				self.driver:set_properties({visual_size = {x=0.1, y=0.1}})
				self.driver:set_eye_offset({x=0,y=2,z=0}, {x=0,y=10,z=-3})
				self.driver:set_animation({x=81, y=161}, 15, 0)

				self.fuel = 15
				if self.fuel then
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
					hud_elem_type = "statbar", -- see HUD element types
					--  ^ type of HUD element, can be either of "image", "text", "statbar", or "inventory"
					position = {x=0.02, y=0.89},
					--  ^ Left corner position of element
					name = "tankhud",
					scale = {x=2, y=2},
					text = "mvehicles_fuel_can.png",
					number = self.fuel_hud_2,
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

				self.shooting_range = 10


				--[[local shooting_range_2 = ((30 - shooting_range_1)^2)^0.5
				local shooting_range_1 = shooting_range_1 - math.abs(shooting_range_1 - 30)
				local shooting_range_2 = shooting_range_2 - (30 - shooting_range_2)]]

				self.shooting_range_hud_l = self.driver:hud_add({
					hud_elem_type = "statbar", -- see HUD element types
					--  ^ type of HUD element, can be either of "image", "text", "statbar", or "inventory"
					position = {x=0.06, y=0.89},
					--  ^ Left corner position of element
					name = "tankhud",
					scale = {x=2, y=2},
					text = "default_mese_crystal.png",
					number = 0,
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
				self.shooting_range_hud_r = self.driver:hud_add({
					hud_elem_type = "statbar", -- see HUD element types
					--  ^ type of HUD element, can be either of "image", "text", "statbar", or "inventory"
					position = {x=0.07, y=0.89},
					--  ^ Left corner position of element
					name = "tankhud",
					scale = {x=2, y=2},
					text = "default_mese_crystal.png",
					number = 0,
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

				self.exhaust = minetest.add_particlespawner(
					{
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
						--  ^ vertical: if true faces player using y axis only
						texture = "tnt_smoke.png",
						--playername = "singleplayer"
						--  ^ Playername is optional, if specified spawns particle only on the player's client
					})

				self.engine_sound = minetest.sound_play("mvehicles_engine", --more sounds needed
					{
						object = self.object,
						gain = 0.5, -- default
						max_hear_distance = 32, -- default, uses an euclidean metric
						loop = true,
					})

			end
		end,


		stop = function(self, vel)
			self.object:set_animation({x=0, y=0}, 0, 0)
			self.object:setvelocity({x=0, y=vel.y, z=0})
		end,


		on_step = function(self, dtime)
			--[[if self.object:getvelocity().z == 0 and self.object:getvelocity().y == 0
				then self.object:setvelocity({x=0, y=5, z=0})
			end]]
			--bouncy tank^
			local vel = self.object:getvelocity()
			if vel.y == 0 and (vel.x ~= 0 or vel.z ~= 0) then
				self.object:setvelocity({x=0, y=0, z=0})
			end
			if not self.driver then
				return
			end
			local yaw = self.object:getyaw()
			local ctrl = self.driver:get_player_control()
			local turned
			local moved
			--if ctrl.aux1 then
				--[[local def.radius = 3
				local def.ignore_protection = 1
				local def.ignore_on_blast = 1
				local pos = self.object:getpos()
				]]
				--tnt.boom(self.object:getpos())
				--shooter:blast(self.object:getpos(), 3, 50, 8, self.driver)
				--tnt_explode(pos, 3, 1, 1)
			--end
			--if not ctrl.sneak then
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
					--self.top:set_animation({x=top_yaw_a,y=top_yaw_a}, 0, 0)
					turned = false
				end
			--[[else
				if ctrl.left then
					self.top_yaw = self.top_yaw+(dtime*50)
				elseif ctrl.right then
					self.top_yaw = self.top_yaw-(dtime*50)
				end
				--top_yaw = self.driver:get_look_horizontal()
				--print(top_yaw)
				if not moved and not turned then
					self.object:set_animation({x=0, y=0}, 0, 0)
				end]]
			--end
				if turned then
					--self.object:setvelocity({x=0, y=vel.y, z=0})
					self.object:setyaw((yaw+2*math.pi)%(2*math.pi))
				else
					if ctrl.up --[[and not turned]] then
							self.object:setvelocity({x=math.cos(yaw+math.pi/2)*2, y=vel.y, z=math.sin(yaw+math.pi/2)*2})
							self.object:set_animation({x=0, y=20}, 30, 0)
							moved = true
						elseif ctrl.down --[[and not turned]] then
							self.object:setvelocity({x=math.cos(yaw+math.pi/2)*-1, y=vel.y, z=math.sin(yaw+math.pi/2)*-1})
							self.object:set_animation({x=20, y=40}, 15, 0)
							moved = true
						else
							--self:stop(vel)
							moved = false
					end
					if ctrl.jump --[[and vel.y == 0]] --[[and not turned]] then
						--self.object:setvelocity({x=vel.x, y=4.7, z=vel.z})
						if self.shootable then
							local shoot = minetest.add_entity(vector.add(self.object:getpos(), {x=0,y=1.2,z=0}), "mvehicles:tank_shoot")
							shoot:setvelocity(
								vector.add(vel,{
									x=(math.cos(self.cannon_direction_horizontal + math.rad(90)))*((math.sin(math.rad(-self.cannon_direction_vertical)))*self.shooting_range),
									y=(math.cos(math.rad(-self.cannon_direction_vertical)))*self.shooting_range,
									z=(math.sin(self.cannon_direction_horizontal + math.rad(90)))*((math.sin(math.rad(-self.cannon_direction_vertical)))*self.shooting_range)
								})
							)

							self.shootable = false
							minetest.after(
								3,
								function(self)
									self.shootable = true
								end,
								self
							)
						end
					end
				end
			end

			--[[if self.shooting_range then
				if ctrl.LMB then
					self.shooting_range = self.shooting_range + dtime
				elseif ctrl.RMB then
					self.shooting_range = self.shooting_range - dtime
				end
			else
				self.shooting_range = 0
			end]]


				--minetest.chat_send_all(-math.deg(self.driver:get_look_vertical())-90)
				--local cannon_pitch = (self.driver:get_look_vertical()--[[-math.pi*0.5]])/(2*math.pi)*360
				--[[local cannon_pitch = math.deg(self.driver:get_look_vertical())
				local cannon_pitch_anim = ((-1) * cannon_pitch) + 370
				self.cannon:set_animation({x=cannon_pitch_anim,y=cannon_pitch_anim}, 0, 0)]]
				--print(cannon_pitch_anim)

			if self.top and not ctrl.sneak then
				self.cannon_direction_horizontal = self.driver:get_look_horizontal()
				self.top:set_bone_position("top_master", {x=0,y=0,z=0}, {x=0,y=-math.deg(self.cannon_direction_horizontal-yaw),z=0})
				self.cannon_direction_vertical = math.max(-100,math.min(-60,(-math.deg(self.driver:get_look_vertical())-90)))
				self.top:set_bone_position(
					"cannon_barrel",
					{x=0,y=1.2,z=0},
					{x=self.cannon_direction_vertical,y=0,z=0}
				)

				--local top_yaw = (self.driver:get_look_horizontal()--[[-math.pi*0.5]])/(2*math.pi)*360
				--local top_yaw_anim = (top_yaw - (yaw*180/math.pi) + 360)%360 + 280
				--self.top:set_animation({x=top_yaw_anim,y=top_yaw_anim}, 0, 0)

				--minetest.chat_send_all(yaw)
				--local top_yaw = self.driver:getyaw() --+280
				--self.top:setyaw(45)--self.driver:getyaw())
				--self.object:set_bone_position("top", self.object:getpos(), {x=0,y=45,z=0})
				--local cannon_pitch = self.driver:get_look_vertical()/math.pi*360
				--print (cannon_pitch)
				--[[if self.top_yaw >= 360 then
					self.top_yaw = self.top_yaw-360
				elseif self.top_yaw <= 0 then
					self.top_yaw = self.top_yaw+360
				end]]
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
	}
)


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
