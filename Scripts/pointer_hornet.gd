@tool
extends Node2D
@export var points: Array[Marker2D]
@export var point_pos: Array[Vector2] = [Vector2.ZERO]
@onready var hornet = $HornetBoss
@export var arena_door: StaticBody2D
signal dead

@export_tool_button("Set Pointer Centre") var set_c = func():
	set_pointer(0)

func _ready() -> void:
	arena_door.boss_start.connect(_boss_start)
	for i in points.size():
		points[i].global_position = point_pos[i]

func set_pointer(i):
	point_pos[i] = self.global_position
	points[i].global_position = self.global_position

func _boss_start() -> void:
	hornet._start_fight()
