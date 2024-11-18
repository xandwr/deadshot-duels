extends CharacterBody3D

@onready var gun_anim_player = $"Head/Camera3D/GunPoint/Assault Rifle/AnimationPlayer"
@onready var gun_cast: RayCast3D = $Head/Camera3D/GunCast
@onready var muzzle: Node3D = $"Head/Camera3D/GunPoint/Assault Rifle/RootNode/AssaultRifle_2/Muzzle"
@onready var muzzle_particles: GPUParticles3D = $"Head/Camera3D/GunPoint/Assault Rifle/RootNode/AssaultRifle_2/Muzzle/GPUParticles3D"
@onready var bullet_impact_particles = preload("res://bullet_impact_particles.tscn")
@onready var shot_sound_source: AudioStreamPlayer3D = $"Head/Camera3D/GunPoint/Assault Rifle/AudioStreamPlayer3D"

var shoot_sounds: Array[AudioStream] = [
	load("res://Sounds/rifle_shot_1.mp3")
]

var move_speed = 4.0


func _physics_process(delta: float) -> void:
	var direction = Vector3(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		0.0,
		Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	).normalized()
	
	var forward = -global_transform.basis.z
	var right = global_transform.basis.x
	
	var world_direction = (right * direction.x + forward * direction.z).normalized()
	
	var target_velocity = world_direction * move_speed
	velocity = lerp(velocity, target_velocity, 0.1)
	
	move_and_slide()
	
	if Input.is_action_pressed("shoot"):
		if !gun_anim_player.is_playing():
			gun_anim_player.play("shoot")
			
			if shot_sound_source:
				shot_sound_source.stream = shoot_sounds.pick_random()
				shot_sound_source.pitch_scale = randf_range(0.9, 1.05)
				shot_sound_source.play()
			
			muzzle_particles.restart()
			
			var has_hit = gun_cast.is_colliding()
			var collision_point = gun_cast.get_collision_point()
			
			if !has_hit:
				collision_point = muzzle.global_position + (-gun_cast.global_transform.basis.z * 100)
			
			var tracer = Tracer.new()
			get_tree().root.add_child(tracer)
			tracer.init(muzzle.global_position, collision_point)
			
			if has_hit:
				var hit = gun_cast.get_collider()
				print("Hit %s at position %s" % [hit.name, collision_point])
				
				var bullet_impact_instance = bullet_impact_particles.instantiate() as GPUParticles3D
				add_child(bullet_impact_instance)
				
				bullet_impact_instance.global_position = collision_point
				bullet_impact_instance.look_at(gun_cast.global_transform.basis.z, gun_cast.get_collision_normal())
				bullet_impact_instance.emitting = true
