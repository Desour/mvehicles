
local gravity = tonumber(minetest.settings:get("movement_gravity")) or 9.81

minetest.register_entity("mvehicles:truck", {
	initial_properties = {
		hp_max = 10,
		physical = true,
		collide_with_objects = true,
		weight = 5,
		collisionbox = {-1,-0.49,-1, 1,1,1},
		visual = "mesh",
		visual_size = {x=10, y=10},
		mesh = "mvehicles_truck.b3d",
		textures = {"mvehicles_truck.png"},
		colors = {},
		spritediv = {x=1, y=1},
		initial_sprite_basepos = {x=0, y=0},
		is_visible = true,
		makes_footstep_sound = false,
		automatic_rotate = 0,
		stepheight = 1.5,
		backface_culling = false,
	},

	on_activate = function(self, staticdata)
		self.object:set_acceleration(vector.new(0, -gravity, 0))
		self.anim_m = 0
		self.anim_t = 0
		self.antiforce = 1
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
			minetest.sound_stop(self.engine_sound)
			player_api.player_attached[self.driver:get_player_name()] = false
			self.driver = nil
		elseif not self.driver and not clicker:get_attach() then
			self.driver = clicker
			player_api.player_attached[self.driver:get_player_name()] = true
			self.driver:set_attach(self.object, "", {x=-0.5,y=0.2,z=0.7}, {x=0,y=0,z=0})
			self.driver:set_properties({visual_size = {x=0.1, y=0.1}})
			self.driver:set_eye_offset({x=-5,y=-1,z=11}, {x=0,y=10,z=-3})
			self.driver:set_animation({x=81, y=161}, 15, 0)
			self.engine_sound = minetest.sound_play("mvehicles_engine", --more sounds needed
				{
					object = self.object,
					gain = 0.5, -- default
					max_hear_distance = 32, -- default, uses an euclidean metric
					loop = true,
				})
		end
	end,

	on_step = function(self, dtime)
		--~ local pos = self.object:get_pos()
		local vel = self.object:get_velocity()
		--[[if vel.y == 0 and (vel.x ~= 0 or vel.z ~= 0) then
			self.object:set_velocity({x=0, y=0, z=0})
		end]]
		if vel.y == 0 then
			local animspeed = (vel.x^2 + vel.z^2)^0.5
			if animspeed > 0.01 then
				animspeed = math.ceil(animspeed)
			end
			self.object:set_animation({x=self.anim_m+self.anim_t+1, y=self.anim_m+self.anim_t+20}, animspeed, 0)
			self.antiforce = 0.95
		else
			self.antiforce = 0.995
		end
		self.object:set_velocity({x=vel.x*self.antiforce,y=vel.y*self.antiforce,z=vel.z*self.antiforce})
		--[[self.object:set_velocity({
			x=vel.x-((vel.x^2)*(vel.x/((vel.x^2)^0.5))*self.antiforce/2),
			y=vel.y-((vel.y^2)*(vel.x/((vel.x^2)^0.5))*self.antiforce/2),
			z=vel.z-((vel.z^2)*(vel.x/((vel.x^2)^0.5))*self.antiforce/2)
		})]]
		if not self.driver then
			return
		end
		local yaw = self.object:get_yaw()
		local ctrl = self.driver:get_player_control()
		local turned -- luacheck: ignore
		local moved -- luacheck: ignore
		if ctrl.sneak then
			self.antiforce = 0.8
			--~ self.object:set_velocity({x=0,y=vel.y,z=0})
			moved = false
		elseif ctrl.up then
			self.object:set_velocity(vector.add(vel, vector.new(
					math.cos(yaw+math.pi/2)*2*dtime,
					0,
					math.sin(yaw+math.pi/2)*2*dtime
				)))
			self.anim_m = 0
			moved = true
		elseif ctrl.down then
			self.object:set_velocity(vector.add(vel, vector.new(
					math.cos(yaw+math.pi/2)*-1*dtime,
					0,
					math.sin(yaw+math.pi/2)*-1*dtime
				)))
			self.anim_m = 20
			moved = true
		else
			moved = false
		end
		-- turn wheels
		if ctrl.left then
			self.anim_t = 80
		elseif ctrl.right then
			self.anim_t = 40
		else
			self.anim_t = 0
		end
		local steer_dir = ctrl.left and 1
				or ctrl.right and -1
				or 0
		local forward = minetest.yaw_to_dir(yaw)
		if vector.dot(forward, vel) < 0 then -- driving backwards
			steer_dir = -steer_dir
		end
		if steer_dir ~= 0 then
			local yaw_n = dtime*math.sqrt(vel.x^2 + vel.z^2)*0.1
			self.object:set_yaw(yaw+steer_dir*yaw_n)
			--~ self.object:set_pos(pos)
			turned = true
		else
			turned = false
		end
	end
})
