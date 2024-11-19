extends Camera3D

@onready var main_camera = $"../../../Head/Camera3D"


func _process(delta: float) -> void:
	global_transform = main_camera.global_transform
