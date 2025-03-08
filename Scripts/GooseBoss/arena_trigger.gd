extends Area2D

@export var tilemap: TileMapLayer
@export var boss: Node2D
@export var bossPos: Marker2D
@export var player: CharacterBody2D
var isTriggered = false

func _on_body_entered(body):
	tilemap = get_node("../Door")
	bossPos = get_node("../CenterMarker")
	player = get_node("../Player")
	if body.name == "Player" and not isTriggered:
		close_door()
		spawn_boss()
		player._boss_camera()
		isTriggered = true
		

func close_door():
	if tilemap:
		tilemap.visible = true
		tilemap.collision_enabled = true
		
func spawn_boss():
	var boss_scene = preload("res://Scenes/GooseBoss/goose_boss.tscn")
	var boss_instance = boss_scene.instantiate()
	get_parent().add_child(boss_instance) 
	boss_instance.global_position = bossPos.global_position  
	boss_instance._start_fight()  
