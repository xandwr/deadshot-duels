extends RigidBody3D

@onready var gun_anim_player = $"Head/Camera3D/GunPoint/Assault Rifle/AnimationPlayer"
@onready var gun_cast: RayCast3D = $Head/Camera3D/GunCast
@onready var bullet_impact_particles = preload("res://bullet_impact_particles.tscn")


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("shoot"):
		if !gun_anim_player.is_playing():
			gun_anim_player.play("shoot")
			
			var hit = gun_cast.get_collider()
			if hit:
				print("Hit %s at position %s" % [hit.name, gun_cast.get_collision_point()])
				
				var bullet_impact_instance = bullet_impact_particles.instantiate() as GPUParticles3D
				add_child(bullet_impact_instance)
				
				bullet_impact_instance.global_position = gun_cast.get_collision_point()

				bullet_impact_instance.look_at(gun_cast.transform.basis.z, gun_cast.get_collision_normal())
				
				bullet_impact_instance.emitting = true
