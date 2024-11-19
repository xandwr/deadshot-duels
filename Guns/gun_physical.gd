extends MeshInstance3D

var sway_min = Vector2(-50, -50)
var sway_max = Vector2(50, 50)
var sway_speed_position = 0.02
var sway_speed_rotation = 0.05
var sway_amount_position = 0.008
var sway_amount_rotation = 30.0

var weapon_position
var weapon_rotation

var mouse_movement = Vector2.ZERO


func _ready() -> void:
	weapon_position = position
	weapon_rotation = rotation_degrees


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_movement = event.relative


func _physics_process(delta: float) -> void:
	# Rough implementation of weapon sway
	# These values actually feel pretty nice, might just keep them long-term
	mouse_movement = mouse_movement.clamp(sway_min, sway_max)
	position.y = lerp(position.x, weapon_position.x - (mouse_movement.x * sway_amount_position) * delta, sway_speed_position)
	position.x = lerp(position.y, weapon_position.y + (mouse_movement.y * sway_amount_position) * delta, sway_speed_position)
	rotation_degrees.x = lerp(rotation_degrees.x, weapon_rotation.y + (mouse_movement.x * sway_amount_rotation) * delta, sway_speed_rotation)
	rotation_degrees.y = lerp(rotation_degrees.y, weapon_rotation.x - (mouse_movement.y * sway_amount_rotation) * delta, sway_speed_rotation)
