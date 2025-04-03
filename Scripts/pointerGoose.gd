@tool
extends Node2D
@export var points: Array[Marker2D]
@export var point_pos: Array[Vector2] = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
@export var arena_door: StaticBody2D
signal dead

@export_tool_button("Set Pointer A") var set_a = func():
	set_pointer(0)
@export_tool_button("Set Pointer B") var set_b = func():
	set_pointer(1)
@export_tool_button("Set Pointer Left") var set_l = func():
	set_pointer(2)
@export_tool_button("Set Pointer Right") var set_r = func():
	set_pointer(3)
@export_tool_button("Set Pointer Centre") var set_c = func():
	set_pointer(4)

@onready var goose = $GooseBoss

func _ready() -> void:
	#arena_door.boss_start.connect(_boss_start)
	for i in points.size():
		points[i].global_position = point_pos[i]

func set_pointer(i):
	point_pos[i] = self.global_position
	points[i].global_position = self.global_position


func _boss_start() -> void:
	goose._start_fight()
