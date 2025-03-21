extends StaticBody2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
var isTriggered = false
signal boss_start

func _ready() -> void:
	collision.disabled = true
	sprite.visible = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player and not isTriggered:
		spawn_boss()
		close_door()
		isTriggered = true

func close_door():
	sprite.visible = true
	collision.set_deferred("disabled", false)
	
		
func spawn_boss():
	boss_start.emit()
