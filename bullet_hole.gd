extends Decal

@export var fade_time: float = 10.0

var time_elapsed: float = 0.0


func _process(delta: float) -> void:
	time_elapsed += delta
	
	modulate.a = 1.0 - (time_elapsed / fade_time)
	
	if time_elapsed >= fade_time:
		queue_free()
