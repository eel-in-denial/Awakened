extends Area2D
@onready var box: CollisionShape2D = $CollisionShape2D

func set_camera_bounds() -> void:
	Global.player.set_camera_limits(box)
