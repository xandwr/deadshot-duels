extends GPUParticles3D

@export var fade_time: float = 1.25
var elapsed_time: float = 0.0


func _ready() -> void:
	lifetime = fade_time


func _process(delta: float) -> void:
	elapsed_time += delta
	
	var material: StandardMaterial3D = self.draw_pass_1.surface_get_material(0)
	material.emission_energy_multiplier = 5.0 - ((elapsed_time / (fade_time * 0.5)) * 5.0)
	
	if elapsed_time >= fade_time:
		queue_free()
