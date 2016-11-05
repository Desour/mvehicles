minetest.register_entity(
	"mvehicles:truck",
	{
		hp_max = 10,
		physical = true,
		collide_with_objects = true,
		weight = 5,
		collisionbox = {-0.5,-0.49,-0.5, 0.5,0.5,0.5},
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
		automatic_face_movement_dir = 0.0,
	--  ^ automatically set yaw to movement direction; offset in degrees; false to disable
		automatic_face_movement_max_rotation_per_sec = -1,
	--  ^ limit automatic rotation to this value in degrees per second. values < 0 no limit
		backface_culling = false, -- false to disable backface_culling for model

		on_activate = function(self, staticdata)
			self.object:setacceleration({x=0, y=-10, z=0})
		end,
	}
)
