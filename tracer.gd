class_name Tracer extends MeshInstance3D

var fade_time = 0.1
var elapsed_time = 0.0

func init(pos1: Vector3, pos2: Vector3):
	material_override = load("res://Materials/tracer.tres")
	
	var draw_mesh_line = ImmediateMesh.new()
	mesh = draw_mesh_line
	
	draw_mesh_line.surface_begin(Mesh.PRIMITIVE_LINES, material_override)
	draw_mesh_line.surface_add_vertex(Vector3.ZERO)
	draw_mesh_line.surface_add_vertex(pos2 - pos1)
	draw_mesh_line.surface_end()
	
	global_transform.origin = pos1
	cast_shadow = ShadowCastingSetting.SHADOW_CASTING_SETTING_OFF


func _process(delta: float) -> void:
	elapsed_time += delta
	self.transparency = 0.0 + (elapsed_time / fade_time)
	
	if elapsed_time >= fade_time:
		queue_free()
