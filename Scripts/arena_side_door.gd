extends StaticBody2D
@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

func close():
	sprite.visible = true
	collision.set_deferred("disabled", false)

func open():
	collision.set_deferred("disabled", true)
	sprite.visible = false
