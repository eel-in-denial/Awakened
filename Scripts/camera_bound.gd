extends Area2D
@export var box: CollisionShape2D

func _ready() -> void:
	var left = box.global_position.x - box.shape.size.x/2
	var right = box.global_position.x + box.shape.size.x/2
	var top = box.global_position.y - box.shape.size.y/2
	var bottom = box.global_position.y + box.shape.size.y/2
	Global.player.set_camera_limits(left, right, top, bottom)
