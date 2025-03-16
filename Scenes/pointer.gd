@tool
extends Node2D

@export_tool_button("Set Pointer A") var set_a = set_pointer_a
@export_tool_button("Set Pointer B") var set_b = set_pointer_b
@export var pointA : Marker2D
@export var pointB : Marker2D
@export var point_a_pos = Vector2.ZERO
@export var point_b_pos = Vector2.ZERO

func _ready() -> void:
	pointA.global_position = point_a_pos
	pointB.global_position = point_b_pos

func set_pointer_a():
	point_a_pos = self.global_position
	pointA.global_position = self.global_position

func set_pointer_b():
	point_b_pos = self.global_position
	pointB.global_position = self.global_position
	
