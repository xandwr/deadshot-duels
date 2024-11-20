extends Node3D

@onready var player = $"."

var sway_min = Vector2(-50, -50)
var sway_max = Vector2(50, 50)
var sway_speed_position = 0.04
var sway_speed_rotation = 0.04
var sway_amount_position = 0.005
var sway_amount_rotation = 30.0

var idle_sway_adjustment = 10.0
var idle_sway_rotation_strength = 300.0
var random_sway_amount = 5.0
var sway_noise = NoiseTexture2D.new()
var sway_speed = 1.2
var random_sway = Vector2()
var sway_time = 0.0

var weapon_position
var weapon_rotation

var mouse_movement = Vector2.ZERO


func _ready() -> void:
	sway_noise.noise = FastNoiseLite.new()
	weapon_position = position
	weapon_rotation = rotation_degrees


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_movement = event.relative


func _physics_process(delta: float) -> void:
	# Rough implementation of weapon sway
	# These values actually feel pretty nice, might just keep them long-term
	var sway_random_noise = get_sway_noise()
	var sway_random_adjusted = sway_random_noise * idle_sway_adjustment
	
	sway_time += delta * (sway_speed + sway_random_noise)
	random_sway.x = sin(sway_time * 1.5 + sway_random_adjusted) / random_sway_amount
	random_sway.y = sin(sway_time - sway_random_adjusted) / random_sway_amount
	
	mouse_movement = mouse_movement.clamp(sway_min, sway_max)
	position.y = lerp(position.x, weapon_position.x - (mouse_movement.x * sway_amount_position + random_sway.x) * delta, sway_speed_position)
	position.x = lerp(position.y, weapon_position.y + (mouse_movement.y * sway_amount_position + random_sway.y) * delta, sway_speed_position)
	rotation_degrees.x = lerp(rotation_degrees.x, weapon_rotation.y + (mouse_movement.x * sway_amount_rotation + (random_sway.y * idle_sway_rotation_strength)) * delta, sway_speed_rotation)
	rotation_degrees.y = lerp(rotation_degrees.y, weapon_rotation.x - (mouse_movement.y * sway_amount_rotation + (random_sway.x * idle_sway_rotation_strength)) * delta, sway_speed_rotation)


func get_sway_noise() -> float:
	var player_position = player.global_position
	return sway_noise.noise.get_noise_2d(player_position.x, player_position.y)
