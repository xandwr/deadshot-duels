extends Node3D

@export var mouse_sensitivity = 0.08
@export var smoothing_factor = 2.8

var pitch = 0.0
var yaw = 0.0
var target_pitch = 0.0
var target_yaw = 0.0
var can_look = true


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		target_pitch += -event.relative.y * mouse_sensitivity
		target_yaw += -event.relative.x * mouse_sensitivity
		target_pitch = clamp(target_pitch, -90.0, 90.0)

	if event.is_action_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			can_look = false
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			can_look = true


func _process(delta: float) -> void:
	if can_look:
		pitch = lerp(pitch, target_pitch, smoothing_factor * delta * 10.0)
		yaw = lerp(yaw, target_yaw, smoothing_factor * delta * 10.0)

		rotation_degrees = Vector3(pitch, yaw, 0)
