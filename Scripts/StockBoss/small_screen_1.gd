extends CharacterBody2D
@onready var hitbox = $Area2D
var player = Global.player

func _physics_process(delta: float) -> void:
	if hitbox.overlaps_body(player):
		player._deal_damage_to_player(1, self)
