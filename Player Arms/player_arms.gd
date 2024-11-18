extends Node3D

@onready var left_arm_ik = $Armature/Skeleton3D/LeftArmIK
@onready var right_arm_ik = $Armature/Skeleton3D/RightArmIK


func _ready() -> void:
	left_arm_ik.start()
	right_arm_ik.start()
