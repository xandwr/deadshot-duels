
# TODO:
# - Add weapon sway/recoil
# - Implement weapon switching/an inventory system
# - Fix muzzle flash + tracer offset issue with varying camera FOV in the subviewport
# - Pause menu / UI
# - Add weapon properties (fire rate, reload time, ammo, etc.)
# - Upgrade movement (just crouching and sliding for now)

extends CharacterBody3D

@onready var main_camera: Camera3D = $Head/Camera3D
@onready var gun_anim_player = $"SubViewportContainer/SubViewport/Camera3D/GunPoint/Assault Rifle/AnimationPlayer"
@onready var gun_cast: RayCast3D = $Head/Camera3D/GunCast
@onready var muzzle: Node3D = $"SubViewportContainer/SubViewport/Camera3D/GunPoint/Assault Rifle/RootNode/AssaultRifle_2/Muzzle"
@onready var muzzle_particles: GPUParticles3D = $"SubViewportContainer/SubViewport/Camera3D/GunPoint/Assault Rifle/RootNode/AssaultRifle_2/Muzzle/GPUParticles3D"
@onready var bullet_impact_particles = preload("res://bullet_impact_particles.tscn")
@onready var bullet_hole = preload("res://bullet_hole.tscn")
@onready var shot_sound_source: AudioStreamPlayer3D = $"SubViewportContainer/SubViewport/Camera3D/GunPoint/Assault Rifle/AudioStreamPlayer3D"
@onready var subviewport: SubViewport = $SubViewportContainer/SubViewport
@onready var subviewport_camera: Camera3D = $SubViewportContainer/SubViewport/Camera3D
@onready var hitmarker_audio_player: AudioStreamPlayer2D = $Head/Camera3D/AudioStreamPlayer2D
@onready var headshot_audio_player: AudioStreamPlayer2D = $Head/Camera3D/AudioStreamPlayer2D2

var is_moving_on_ground: bool = false
var input_direction: Vector2 = Vector2.ZERO

var shoot_sounds: Array[AudioStream] = [
	load("res://Sounds/rifle_shot_1.mp3")
]

var walk_speed = 4.0
var sprint_speed = 6.5
var current_move_speed = 0.0
var jump_force = 4.0

var original_fov
var camera_fov_speed = 0.025


func _ready() -> void:
	# Some projection hackery to adjust the offset of the muzzle to match the FOV of the subviewport camera
	var muzzle_screenspace = subviewport_camera.unproject_position(muzzle.global_transform.origin)
	var muzzle_world_adjusted = main_camera.project_position(muzzle_screenspace, 0.5)
	muzzle.global_transform.origin = muzzle_world_adjusted
	
	original_fov = main_camera.fov


func _process(delta: float) -> void:
	if current_move_speed == sprint_speed:
		main_camera.fov = lerp(main_camera.fov, original_fov + 10, camera_fov_speed)
	else:
		main_camera.fov = lerp(main_camera.fov, original_fov, camera_fov_speed)


func _physics_process(delta: float) -> void:
	is_moving_on_ground = (input_direction != Vector2.ZERO) and is_on_floor()
	
	_handle_movement(delta)
	
	if Input.is_action_pressed("shoot"):
		if !gun_anim_player.is_playing():
			_handle_shoot()


func _handle_movement(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	input_direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	).normalized()
	
	var forward = -global_transform.basis.z
	var right = global_transform.basis.x
	
	var world_direction = (right * input_direction.x + forward * input_direction.y).normalized()
	var target_velocity
	
	if Input.is_action_pressed("sprint"):
		target_velocity = world_direction * sprint_speed
		current_move_speed = sprint_speed
	else:
		target_velocity = world_direction * walk_speed
		current_move_speed = walk_speed
	
	velocity = lerp(velocity, Vector3(target_velocity.x, velocity.y, target_velocity.z), 0.08)
	move_and_slide()


func _handle_shoot() -> void:
	gun_anim_player.play("shoot")
	_play_shoot_sound()
	muzzle_particles.restart()
	
	var hit_instance = gun_cast.get_collider()
	var has_hit = gun_cast.is_colliding()
	var collision_point = gun_cast.get_collision_point()
	var collision_normal = gun_cast.get_collision_normal()
	
	if !has_hit:
		collision_point = muzzle.global_position + (-gun_cast.global_transform.basis.z * 100)
	
	_spawn_bullet_tracer(collision_point)
	
	if has_hit:		
		_spawn_bullet_hole(collision_point, collision_normal)
		if hit_instance.is_in_group("EnemyHead"):
			if hit_instance.get_parent().is_alive:
				headshot_audio_player.play()
			hit_instance.get_parent().damage(60.0, hit_instance.get_parent().global_transform.origin - global_transform.origin)
		elif hit_instance.is_in_group("EnemyBody"):
			if hit_instance.get_parent().is_alive:
				hitmarker_audio_player.play()
			hit_instance.get_parent().damage(35.0, hit_instance.get_parent().global_transform.origin - global_transform.origin)


func _spawn_bullet_hole(collision_point: Vector3, collision_normal: Vector3) -> void:
	var bullet_hole_instance = bullet_hole.instantiate() as Decal
	get_tree().root.add_child(bullet_hole_instance)
	
	var bullet_impact_instance = bullet_impact_particles.instantiate() as GPUParticles3D
	get_tree().root.add_child(bullet_impact_instance)
	
	bullet_hole_instance.global_position = collision_point
	bullet_impact_instance.global_position = collision_point
	
	# Rotate the bullet hole instance to look towards the impact surface normal
	if not Vector3.UP.cross((collision_point + collision_normal) - bullet_hole_instance.global_position).is_zero_approx():
		bullet_hole_instance.look_at(collision_point + collision_normal, Vector3.UP)
	
	# Rotate the bullet impact particles to face away from the shot origin
	var shot_direction = (muzzle.global_transform.origin - collision_point).normalized()
	bullet_impact_instance.look_at(collision_point + shot_direction, Vector3.UP)
	
	# If the normal isn't straight up or down, then rotate 90 degrees left
	if collision_normal != Vector3.UP and collision_normal != Vector3.DOWN:
		bullet_hole_instance.rotate_object_local(-Vector3.RIGHT, 90)
		bullet_impact_instance.rotate_object_local(-Vector3.RIGHT, 90)
	
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
