class_name Tracer extends MeshInstance3D

var fade_time = 0.25
var elapsed_time = 0.0

func init(pos1, pos2):
	material_override = load("res://Materials/tracer.tres")
	
	global_transform.origin = pos1
	
	var draw_mesh = ImmediateMesh.new()
	mesh = draw_mesh
	draw_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material_override)
	draw_mesh.surface_add_vertex(Vector3.ZERO)
	draw_mesh.surface_add_vertex(global_transform.basis * (pos2 - pos1))
	draw_mesh.surface_end()


func _process(delta: float) -> void:
	elapsed_time += delta
	self.transparency = 0.0 + (elapsed_time / fade_time)
	
	if elapsed_time >= fade_time:
		queue_free()
