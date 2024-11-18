extends Node3D

const SPEED = 40.0

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var particles: GPUParticles3D = $GPUParticles3D


func _physics_process(delta: float) -> void:
	var movement = transform.basis * Vector3(0, 0, -SPEED) * delta
	var start_pos = global_position
	var end_pos = global_position + movement

	var space_state = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.create(start_pos, end_pos)
	var result = space_state.intersect_ray(params)

	if result:
		print("Bullet collided with:", result.collider.name)
		mesh.visible = false
		particles.emitting = true
		await get_tree().create_timer(1.0).timeout
		queue_free()
	else:
		position += movement


func _on_timer_timeout() -> void:
	queue_free()
