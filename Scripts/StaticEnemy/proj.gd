extends Area2D

@export var speed = 400.0
var direction = Vector2.ZERO
var shooter: Node2D = null

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body == shooter:
		return

	if body is Player:
		body._deal_damage_to_player(1, self)
	queue_free()
