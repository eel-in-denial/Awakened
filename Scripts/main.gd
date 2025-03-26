class_name Main extends Node2D

@onready var room = $Room
@onready var player = $Player
var adjacent_rooms: Dictionary[Area2D, Node2D]

var current_room = load("res://Scenes/1_Rooms/first_room.tscn").instantiate()
var prev_room: Node2D

func _ready() -> void:
	remove_child(player)
	Global.main = self
	room.add_child(current_room)
	load_rooms(current_room.get_node("Doors").adjacent_rooms) 
	set_player_pos(current_room.get_node("Player Spawn").global_position)
	

func change_scene(key: Area2D):
	player.loaded = false
	remove_child(player)
	
	prev_room = current_room
	room.remove_child(current_room)
	room.add_child(adjacent_rooms[key])
	current_room = adjacent_rooms[key]
	adjacent_rooms.clear()
	load_rooms(current_room.get_node("Doors").adjacent_rooms)
	
	
	

func set_player_pos(position):
	player.set_global_position(position)
	add_child(player)

func load_rooms(room_paths: Dictionary[Area2D, String]):
	for room in room_paths:
		adjacent_rooms[room] = load(room_paths[room]).instantiate()
	
