extends Node2D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/0_MainScenes/Main.tscn")
