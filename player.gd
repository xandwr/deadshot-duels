
# TODO:
# - Make player guns local to their viewport (to prevent clipping into walls)
# - Weapon sway/recoil
# - Upgrade weapon sounds
# - Implement weapon switching/an inventory system

extends CharacterBody3D

@onready var gun_anim_player = $"Head/Camera3D/GunPoint/Assault Rifle/AnimationPlayer"
@onready var gun_cast: RayCast3D = $Head/Camera3D/GunCast
@onready var muzzle: Node3D = $"Head/Camera3D/GunPoint/Assault Rifle/RootNode/AssaultRifle_2/Muzzle"
@onready var muzzle_particles: GPUParticles3D = $"Head/Camera3D/GunPoint/Assault Rifle/RootNode/AssaultRifle_2/Muzzle/GPUParticles3D"
@onready var bullet_impact_particles = preload("res://bullet_impact_particles.tscn")
@onready var bullet_hole = preload("res://bullet_hole.tscn")
@onready var shot_sound_source: AudioStreamPlayer3D = $"Head/Camera3D/GunPoint/Assault Rifle/AudioStreamPlayer3D"

var shoot_sounds: Array[AudioStream] = [
	load("res://Sounds/rifle_shot_1.mp3")
]

var move_speed = 4.0
var jump_force = 4.0


func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	
	if Input.is_action_pressed("shoot"):
		if !gun_anim_player.is_playing():
			_handle_shoot()


func _handle_movement(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var direction = Vector3(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		0.0,
		Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	).normalized()
	
	var forward = -global_transform.basis.z
	var right = global_transform.basis.x
	
	var world_direction = (right * direction.x + forward * direction.z).normalized()
	
	var target_velocity = world_direction * move_speed
	
	velocity = lerp(velocity, Vector3(target_velocity.x, velocity.y, target_velocity.z), 0.08)
	move_and_slide()


func _handle_shoot() -> void:
	gun_anim_player.play("shoot")
	_play_shoot_sound()
	muzzle_particles.restart()
	
	var has_hit = gun_cast.is_colliding()
	var collision_point = gun_cast.get_collision_point()
	var collision_normal = gun_cast.get_collision_normal()
	
	if !has_hit:
		collision_point = muzzle.global_position + (-gun_cast.global_transform.basis.z * 100)
	
	_spawn_bullet_tracer(collision_point)
	
	if has_hit:		
		_spawn_bullet_hole(collision_point, collision_normal)


func _spawn_bullet_hole(collision_point: Vector3, collision_normal: Vector3) -> void:
	var bullet_hole_instance = bullet_hole.instantiate() as Decal
	get_tree().root.add_child(bullet_hole_instance)
	
	bullet_hole_instance.global_position = collision_point
	
	# Rotate the bullet hole instance to look towards the impact surface normal
	if not Vector3.UP.cross((collision_point + collision_normal) - bullet_hole_instance.global_position).is_zero_approx():
		bullet_hole_instance.look_at(collision_point + collision_normal, Vector3.UP)
	
	# If the normal isn't straight up or down, then rotate 90 degrees left
	if collision_normal != Vector3.UP and collision_normal != Vector3.DOWN:
		bullet_hole_instance.rotate_object_local(-Vector3.RIGHT, 90)
	
	var bullet_impact_instance = bullet_impact_particles.instantiate() as GPUParticles3D
	get_tree().root.add_child(bullet_impact_instance)
	
	bullet_impact_instance.global_position = collision_point
	bullet_impact_instance.look_at(gun_cast.global_transform.basis.z, collision_normal)
	bullet_impact_instance.emitting = true


func _spawn_bullet_tracer(collision_point: Vector3) -> void:
	var tracer = Tracer.new()
	get_tree().root.add_child(tracer)
	tracer.init(muzzle.global_position, collision_point)


func _play_shoot_sound() -> void:
	if shot_sound_source:
		shot_sound_source.stream = shoot_sounds.pick_random()
		shot_sound_source.pitch_scale = randf_range(0.9, 1.05)
		shot_sound_source.play()
