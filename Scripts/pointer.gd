@tool
extends Node2D
@export var points: Array[Marker2D]
@export var point_pos: Array[Vector2] = [Vector2.ZERO, Vector2.ZERO]

@export_tool_button("Set Pointer A") var set_a = func():
	set_pointer(0)
@export_tool_button("Set Pointer B") var set_b = func():
	set_pointer(1)
	
func _ready() -> void:
	for i in points.size():
		points[i].global_position = point_pos[i]

func set_pointer(i):
	point_pos[i] = self.global_position
	points[i].global_position = self.global_position
