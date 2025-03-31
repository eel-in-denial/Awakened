extends Camera2D

@onready var player = Global.player
var distance_to_player = 50

func _process(delta: float) -> void:
	if global_position.distance_to(player.global_position) > distance_to_player:
		global_position = player.global_position + player.global_position.direction_to(global_position)*distance_to_player
	elif global_position != player.global_position:
		global_position = global_position.move_toward(player.global_position, 2)
