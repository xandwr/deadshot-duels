extends RigidBody3D

var bullet = load("res://bullet.tscn")
var bullet_instance

@onready var gun_anim_player = $"Head/Camera3D/GunPoint/Assault Rifle/AnimationPlayer"
@onready var gun_raycast = $"Head/Camera3D/GunPoint/Assault Rifle/RayCast3D"


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("shoot"):
		if !gun_anim_player.is_playing():
			gun_anim_player.play("shoot")
			bullet_instance = bullet.instantiate()
			bullet_instance.position = gun_raycast.global_position
			bullet_instance.transform.basis = gun_raycast.global_transform.basis
			get_parent().add_child(bullet_instance)
