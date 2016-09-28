minetest.register_entity(
	"mvehicles:tank_cannon",
	{
		hp_max = 1,
		physical = false,
		weight = 5,
		collisionbox = {-1,-1,-1, 1,1,1},
		visual = "mesh",
		visual_size = {x=1, y=1},
		mesh = "mvehicles_tank_cannon_tt.b3d",
		textures = {"mvehicles_tank.png"}, -- number of required textures depends on visual
		colors = {}, -- number of required colors depends on visual
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

		on_activate = function(self, staticdata)
			self.object:set_animation({x=280, y=280}, 0, 0)
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
		collisionbox = {-1,-1,-1, 1,1,1},
		visual = "mesh",
		visual_size = {x=1, y=1},
		mesh = "mvehicles_tank_top_tt.b3d",
		textures = {"mvehicles_tank.png"}, -- number of required textures depends on visual
		colors = {}, -- number of required colors depends on visual
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
		textures = {"mvehicles_tank.png"}, -- number of required textures depends on visual
		colors = {}, -- number of required colors depends on visual
		spritediv = {x=1, y=1},
		initial_sprite_basepos = {x=0, y=0},
		is_visible = true,
		makes_footstep_sound = false,
		automatic_rotate = false,

		on_activate = function(self, staticdata)
			--self.top_yaw_anim = 280
			--if staticdata == "" then
				self.top = minetest.add_entity(self.object:getpos(), "mvehicles:tank_top")
				self.cannon = minetest.add_entity(self.object:getpos(), "mvehicles:tank_cannon")
			--else
				--local topn = minetest.get_objects_inside_radius(self.object:getpos(), 1)[1]
				--top = get_staticdata
			--end
			if self.top then
				self.top:set_attach(self.object, "", {x=0,y=0,z=0}, {x=0,y=0,z=0})
			end
			if self.cannon then
				self.cannon:set_attach(self.object, "", {x=0,y=0,z=0}, {x=0,y=0,z=0})
			end

			self.object:setacceleration({x=0, y=-10, z=0})

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
				self.driver = nil
				self.object:set_animation({x=0, y=0}, 0, 0)
				minetest.delete_particlespawner(self.exhaust)
				minetest.sound_stop(self.engine_sound)
			else
				self.driver:set_attach(self.object, "", {x=0,y=0,z=0}, {x=0,y=0,z=0})
				self.driver:set_properties({visual_size = {x=0.1, y=0.1}})
				self.driver:set_eye_offset({x=0,y=2,z=0}, {x=0,y=10,z=-3})
				self.driver:set_animation({x=81, y=161}, 15, 0)
				self.exhaust = minetest.add_particlespawner( --hoping that pull request "Attached Particle Spawners #4409" gets merged
					{
						amount = 10,
						time = 0,
						--  ^ If time is 0 has infinite lifespan and spawns the amount on a per-second base
						minpos = self.object:getpos(),
						maxpos = self.object:getpos(),
						minvel = {x=0, y=1, z=0},
						maxvel = {x=0, y=1.5, z=0},
						minacc = {x=0, y=0, z=0},
						maxacc = {x=0, y=0, z=0},
						minexptime = 1,
						maxexptime = 2,
						minsize = 1,
						maxsize = 3,
						--  ^ The particle's properties are random values in between the bounds:
						--  ^ minpos/maxpos, minvel/maxvel (velocity), minacc/maxacc (acceleration),
						--  ^ minsize/maxsize, minexptime/maxexptime (expirationtime)
						collisiondetection = true,
						--  ^ collisiondetection: if true uses collision detection
						collision_removal = false,
						--  ^ collision_removal: if true then particle is removed when it collides,
						--  ^ requires collisiondetection = true to have any effect
						vertical = false,
						--  ^ vertical: if true faces player using y axis only
						texture = "tnt_smoke.png",
						--  ^ Uses texture (string)
						--playername = "singleplayer"
						--  ^ Playername is optional, if specified spawns particle only on the player's client
					})
				--self.exhaust:set_attach(self.object, "", {x=0,y=0,z=0}, {x=0,y=0,z=0})
				self.engine_sound = minetest.sound_play("default_cool_lava", --better sound needed
					{
						object = self.object,
						gain = 0.5, -- default
						max_hear_distance = 32, -- default, uses an euclidean metric
						loop = true, -- only sounds connected to objects can be looped
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
					self.top:set_animation({x=top_yaw_a,y=top_yaw_a}, 0, 0)
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
				if ctrl.jump and vel.y == 0 --[[and not turned]] then
					self.object:setvelocity({x=vel.x, y=4.7, z=vel.z})
				end
			end

			if self.cannon then
				local cannon_pitch = (self.driver:get_look_vertical()--[[-math.pi*0.5]])/(2*math.pi)*360
				local cannon_pitch_anim = ((-1) * cannon_pitch) + 370
				self.cannon:set_animation({x=cannon_pitch_anim,y=cannon_pitch_anim}, 0, 0)
				print(cannon_pitch_anim)
			end

			--if self.top then

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
			--end
		end
	}
)
