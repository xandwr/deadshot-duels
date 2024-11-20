class_name Enemy extends Node3D

@onready var label: Label3D = $Label3D

@export var max_health: float = 100.0
var health: float
var is_alive: bool = true
var is_attached: bool = true
var despawn_timer: float = 0.0
var despawn_time: float = 10.0

var last_hit_dir = Vector3()


func _ready() -> void:
	health = max_health
	label.text = "Health: %s/%s" % [self.health, self.max_health]


func _physics_process(delta: float) -> void:
	if not is_alive:
		label.text = ""
		despawn_timer += delta

		for child in get_children():
			if child is RigidBody3D:
				if is_attached:
					child.apply_impulse(last_hit_dir * 5)
					is_attached = false
				
				child.set_collision_layer_value(1, false)
				
				for subchild in child.get_children():
					if subchild is MeshInstance3D:
						subchild.cast_shadow = false
						subchild.transparency = despawn_timer / despawn_time
		
		if despawn_timer >= despawn_time:
			queue_free()


func damage(damage: float, direction: Vector3):
	if is_alive:
		last_hit_dir = direction
		
		self.health -= damage
		label.text = "Health: %s/%s" % [self.health, self.max_health]
		
		if self.health <= 0:
			is_alive = false
