extends Node3D

# very bad solution, needs redoing...
# actually, currently this entire project has terrible design,
# but i would like to actually get features implemented, so it stays for now.
@onready var player = $"../../../../../.."

var sway_min = Vector2(-50, -50)
var sway_max = Vector2(50, 50)
var sway_speed_position = 0.03
var sway_speed_rotation = 0.03
var sway_amount_position = 0.05
var sway_amount_rotation = 30.0

var idle_sway_adjustment = 10.0
var idle_sway_rotation_strength = 500.0
var random_sway_amount = 5.0
var sway_noise = NoiseTexture2D.new()
var sway_speed = 0.5
var random_sway = Vector2()
var sway_time = 0.0

var bob_speed = 1
var hbob_amount = 1
var vbob_amount = 1
var weapon_bob_amount = Vector2()
var bob_time = 0.0

var fall_rotation_amount: float = 0.0

var weapon_position
var weapon_rotation

var mouse_movement = Vector2()


func _ready() -> void:
	sway_noise.noise = FastNoiseLite.new()
	weapon_position = position
	weapon_rotation = rotation_degrees


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_movement = event.relative


func _process(delta: float) -> void:
	mouse_movement = Vector2.ZERO # Reset the mouse movement each frame to prevent tab-out issues
	bob_speed = player.current_move_speed * 1.8
	hbob_amount = player.current_move_speed * 0.25
	vbob_amount = player.current_move_speed * 0.25


func _physics_process(delta: float) -> void:
	handle_weapon_sway(delta)


func handle_weapon_sway(delta: float) -> void:
	# Rough implementation of weapon sway
	# These values actually feel pretty nice, might just keep them long-term
	var sway_random_noise = get_sway_noise()
	var sway_random_adjusted = sway_random_noise * idle_sway_adjustment
	
	sway_time += delta * (sway_speed + sway_random_noise)
	random_sway.x = sin(sway_time * 1.5 + sway_random_adjusted) / random_sway_amount
	random_sway.y = sin(sway_time - sway_random_adjusted) / random_sway_amount
	
	bob_time += delta
	weapon_bob_amount.x = sin(bob_time * bob_speed) * hbob_amount
	weapon_bob_amount.y = abs(cos(bob_time * bob_speed) * vbob_amount)
	
	fall_rotation_amount = clampf(rad_to_deg(player.velocity.y) * 4, -4000, 4000)
	
	mouse_movement = mouse_movement.clamp(sway_min, sway_max)
	
	# NOTE:
	# Because of the way I imported the weapon models, the orientation is all fucked up.
	# This means that the weapon 'y' position controls horiz. movement, and the 'z' controls vert.
	# Will fix this eventually.
	if player.is_moving_on_ground:
		position.y = lerp(position.y, weapon_position.x - (mouse_movement.x * sway_amount_position + random_sway.x + weapon_bob_amount.x) * delta, sway_speed_position)
		position.z = lerp(position.z, weapon_position.y + (mouse_movement.y * sway_amount_position + random_sway.y + weapon_bob_amount.y) * delta, sway_speed_position)
	else:
		bob_time = 0.0
		position.y = lerp(position.y, weapon_position.x - (mouse_movement.x * sway_amount_position + random_sway.x) * delta, sway_speed_position)
		position.z = lerp(position.z, weapon_position.y + (mouse_movement.y * sway_amount_position + random_sway.y) * delta, sway_speed_position)
	
	rotation_degrees.x = lerp(rotation_degrees.x, weapon_rotation.y - (mouse_movement.x * sway_amount_rotation + (random_sway.y * idle_sway_rotation_strength)) * delta, sway_speed_rotation)
	rotation_degrees.y = lerp(rotation_degrees.y, weapon_rotation.x - (mouse_movement.y * sway_amount_rotation + (random_sway.x * idle_sway_rotation_strength) - fall_rotation_amount) * delta, sway_speed_rotation)


func get_sway_noise() -> float:
	var player_position = player.global_position
	return sway_noise.noise.get_noise_2d(player_position.x, player_position.y)
