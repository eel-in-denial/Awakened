extends Node2D

@export var adjacent_rooms: Dictionary[Area2D, String]

func _ready() -> void:
	for door in adjacent_rooms:
		if Global.main.prev_room != null and Global.main.prev_room.scene_file_path == adjacent_rooms[door]:
			Global.main.set_player_pos(door.get_node("Marker2D").global_position)
		door.body_entered.connect(_on_body_entered.bind(door))
		
func _on_body_entered(body: Node2D, door: Area2D):
	if body is Player and body.loaded == true: 
		Global.main.call_deferred("change_scene", door)
