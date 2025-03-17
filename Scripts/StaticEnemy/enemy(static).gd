extends CharacterBody2D

const SPEED: float = 200.0
@export var detection_range: float = 150.0
@export var burst_duration: float = 0.5
@export var burst_cooldown: float = 0.5
@onready var shriek_projectile = preload("res://Scenes/StaticEnemy/proj.tscn")

@onready var player = Global.player
@onready var current_state = "Idle"
var burst_timer = 0.0
var cooldown_timer = 0.0
var detectionRange := 150.0
var health := 2

var projectile_fired: bool = false

func _ready():
	pass

func _physics_process(delta):
	match current_state:
		"Idle":
			if _detect_player():
				current_state = "Chasing"
		"Chasing":
			chase_player(delta)

func _detect_player() -> bool:
	if global_position.distance_to(player.global_position) <= detectionRange:
		return true
	return false

func chase_player(delta):
	if burst_timer > 0:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * SPEED
		burst_timer -= delta
	else:
		velocity = Vector2.ZERO
		if not projectile_fired:
			fire_proj()
			projectile_fired = true

		cooldown_timer -= delta
		if cooldown_timer <= 0:
			burst_timer = burst_duration
			cooldown_timer = burst_cooldown
			projectile_fired = false

	move_and_slide()

func fire_proj() -> void:
	var projectile = shriek_projectile.instantiate()
	projectile.global_position = global_position
	projectile.direction = (player.global_position - global_position).normalized()
	projectile.shooter = self 
	get_parent().add_child(projectile)
	
func _on_enemy_body_contact(body: Node2D) -> void:
	if body is Player:
		body._deal_damage_to_player(1, global_position)
	
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Player:
		body._deal_damage_to_player(1, global_position)
	
func _deal_damage(damage: int) -> void:
	health -= damage
	velocity.y = -200
	if health <= 0:
		_die()

func _die() -> void:
		queue_free()
