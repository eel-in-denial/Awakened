extends StaticBody2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@export var camera_bounds: Area2D
@export var boss: Node2D
var isTriggered = false
signal boss_start

func _ready() -> void:
	collision.disabled = true
	sprite.visible = false
	boss.dead.connect(_on_boss_dead)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player and not isTriggered:
		spawn_boss()
		close_door()
		camera_bounds.set_camera_bounds()
		isTriggered = true

func close_door():
	sprite.visible = true
	collision.set_deferred("disabled", false)
	
		
func spawn_boss():
	boss_start.emit()


func _on_boss_dead() -> void:
	collision.set_deferred("disabled", true)
	sprite.visible = false
	Global.main.current_room.get_node("Camera Bound").set_camera_bounds()
	
