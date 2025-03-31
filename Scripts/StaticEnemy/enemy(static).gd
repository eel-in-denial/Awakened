extends CharacterBody2D

const SPEED: float = 200.0
@export var detection_range: float = 150.0
@export var burst_duration: float = 0.5
@export var burst_cooldown: float = 0.5
@onready var hitbox: Area2D = $Hitbox
@onready var shriek_projectile = preload("res://Scenes/Enemies/StaticEnemy/proj.tscn")

@onready var player = Global.player
@onready var currentState = "Idle"
var burst_timer = 0.0
var cooldown_timer = 0.0
var detectionRange := 150.0
var health := 2

var projectile_fired: bool = false

func _ready():
	pass

func _physics_process(delta):
	if hitbox.overlaps_body(player):
		player._deal_damage_to_player(1, self)
		
	match currentState:
		"Idle":
			if _detect_player():
				currentState = "Chasing"
		"Chasing":
			chase_player(delta)
		"Knockback":
			_knockback(delta)

func _detect_player() -> bool:
	return global_position.distance_to(player.global_position) <= detectionRange

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

func _knockback(delta):
	var knockback_direction = (global_position - player.global_position).normalized()
	velocity = knockback_direction * 250  # Knockback speed of 250 pixels
	move_and_slide()
	
	await get_tree().create_timer(0.3).timeout 

	currentState = "Chasing"

func fire_proj() -> void:
	var projectile = shriek_projectile.instantiate()
	projectile.global_position = global_position
	projectile.direction = (player.global_position - global_position).normalized()
	projectile.shooter = self 
	get_parent().add_child(projectile)
	
func set_knockback():
	currentState = "Knockback"
	
func _deal_damage(damage: int) -> void:
	health -= damage

	set_knockback()

	if health <= 0:
		_die()

func _die() -> void:
	queue_free()
