--[[
  __                        __
_/  |________ __ __   ____ |  | __
\   __\_  __ \  |  \_/ ___\|  |/ /
 |  |  |  | \/  |  /\  \___|    <
 |__|  |__|  |____/  \___  >__|_ \
                         \/     \/
]]

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
			self.object:setacceleration({x=0, y=-tonumber(minetest.setting_get("movement_gravity")), z=0})
			self.anim_m = 0
			self.anim_t = 0
			self.antiforce = 1
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
				default.player_attached[self.driver:get_player_name()] = false
				self.driver = nil
			elseif not self.driver and not clicker:get_attach() then
				self.driver = clicker
				default.player_attached[self.driver:get_player_name()] = true
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
			local pos = self.object:getpos()
			local vel = self.object:getvelocity()
			local acc = self.object:getacceleration()
			--[[if vel.y == 0 and (vel.x ~= 0 or vel.z ~= 0) then
				self.object:setvelocity({x=0, y=0, z=0})
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
			self.object:setvelocity({x=vel.x*self.antiforce,y=vel.y*self.antiforce,z=vel.z*self.antiforce})
			--[[self.object:setvelocity({
				x=vel.x-((vel.x^2)*(vel.x/((vel.x^2)^0.5))*self.antiforce/2),
				y=vel.y-((vel.y^2)*(vel.x/((vel.x^2)^0.5))*self.antiforce/2),
				z=vel.z-((vel.z^2)*(vel.x/((vel.x^2)^0.5))*self.antiforce/2)
			})]]
			if not self.driver then
				return
			end
			local yaw = self.object:getyaw()
			local ctrl = self.driver:get_player_control()
			local turned
			local moved
			if ctrl.sneak then
				self.antiforce = 0.8
				--~ self.object:setvelocity({x=0,y=vel.y,z=0})
				moved = false
			elseif ctrl.up then
				self.object:setvelocity(vector.add(vel,{x=math.cos(yaw+math.pi/2)*2*dtime, y=0, z=math.sin(yaw+math.pi/2)*2*dtime}))
				self.anim_m = 0
				moved = true
			elseif ctrl.down then
				self.object:setvelocity(vector.add(vel,{x=math.cos(yaw+math.pi/2)*-1*dtime, y=0, z=math.sin(yaw+math.pi/2)*-1*dtime}))
				self.anim_m = 20
				moved = true
			else
				moved = false
			end
			if ctrl.left then
				local yaw_n = dtime*((vel.x^2 + vel.z^2)^0.5)/10
				self.object:setyaw(yaw+yaw_n)
				self.object:setpos(pos)
				self.anim_t = 80
				turned = true
			elseif ctrl.right then
				local yaw_n = dtime*((vel.x^2 + vel.z^2)^0.5)/10
				self.object:setyaw(yaw-yaw_n)
				self.object:setpos(pos)
				self.anim_t = 40
				turned = true
			else
				self.anim_t = 0
				turned = false
			end
		end
	}
)
