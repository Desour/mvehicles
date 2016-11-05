minetest.register_entity(
	"mvehicles:truck",
	{
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
		automatic_rotate = false,
		stepheight = 1.5,
		--automatic_face_movement_dir = 0.0,
	--  ^ automatically set yaw to movement direction; offset in degrees; false to disable
		--automatic_face_movement_max_rotation_per_sec = -1,
	--  ^ limit automatic rotation to this value in degrees per second. values < 0 no limit
		backface_culling = false, -- false to disable backface_culling for model

		on_activate = function(self, staticdata)
			self.object:setacceleration({x=0, y=-10, z=0})
		end,

		on_rightclick =function(self, clicker)
			if not clicker or not clicker:is_player() then
				return
			end
			if clicker == self.driver then
				self.driver:set_detach()
				self.driver:set_properties({visual_size = {x=1, y=1}})
				self.driver:set_eye_offset({x=0,y=0,z=0}, {x=0,y=0,z=0})
				self.object:set_animation({x=0, y=0}, 0, 0)
				minetest.sound_stop(self.engine_sound)
				self.driver = nil
			elseif not self.driver and not clicker:get_attach() then
				self.driver = clicker
				self.driver:set_attach(self.object, "", {x=-0.5,y=0.8,z=0.7}, {x=0,y=0,z=0})
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
			if ctrl.up --[[and not turned]] then
				self.object:setvelocity({x=math.cos(yaw+math.pi/2)*2, y=vel.y, z=math.sin(yaw+math.pi/2)*2})
				self.object:set_animation({x=1, y=20}, 30, 0)
				moved = true
			elseif ctrl.down --[[and not turned]] then
				self.object:setvelocity({x=math.cos(yaw+math.pi/2)*-1, y=vel.y, z=math.sin(yaw+math.pi/2)*-1})
				self.object:set_animation({x=21, y=40}, 15, 0)
				moved = true
			else
				--self:stop(vel)
				moved = false
			end
		end
	}
)
