extends Node2D

@onready var label: Label = $Label

var lifetime = 1.0
var time_elapsed: float = 0.0


func _process(delta: float) -> void:
	time_elapsed += delta
	
	modulate.a = 1.0 - (time_elapsed / lifetime)
	
	if time_elapsed >= lifetime:
		queue_free()
