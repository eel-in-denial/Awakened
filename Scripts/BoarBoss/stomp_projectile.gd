extends Area2D

@export var speed = 500.0
var direction = Vector2.ZERO

func _physics_process(delta):
	position += direction * speed * delta
	
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body._deal_damage_to_player(1, self)
