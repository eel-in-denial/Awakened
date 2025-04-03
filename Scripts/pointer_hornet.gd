@tool
extends Node2D
@export var points: Array[Marker2D]
@export var point_pos: Array[Vector2] = [Vector2.ZERO]
@onready var hornet = $HornetBoss
signal dead

@export_tool_button("Set Pointer Centre") var set_c = func():
	set_pointer(0)

func _ready() -> void:
	for i in points.size():
		points[i].global_position = point_pos[i]

func set_pointer(i):
	point_pos[i] = self.global_position
	points[i].global_position = self.global_position

func _on_arena_door_boss_start() -> void:
	hornet._start_fight()
