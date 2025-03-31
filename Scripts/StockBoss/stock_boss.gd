extends CharacterBody2D

const FALL_SPEED = 400.0
const RETURN_SPEED = 300.0
const ARROW_SPEED = 250.0
const EXPLOSION_DELAY = 1.0

var health = 50
@onready var hitbox: Area2D = $Hitbox
@onready var attack_timer: Timer = $AttackTimer
@onready var player = Global.player
@onready var stomp_projectile = preload("res://Scenes/BoarBoss/stomp_projectile.tscn")
#@onready var arrow_projectile = preload("res://Scenes/StockMarketBoss/arrow_projectile.tscn")
#@onready var explosion_projectile = preload("res://Scenes/StockMarketBoss/explosion_projectile.tscn")
@onready var small_screens = [$SmallScreen1, $SmallScreen2, $SmallScreen3, $SmallScreen4]

var currentState : String
var original_position: Vector2
var ultimate_started = false

signal dead

func _ready() -> void:
	original_position = global_position
	_start_fight()

func _start_fight() -> void:
	await get_tree().create_timer(2.0).timeout
	attack_timer.wait_time = 3.0
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	attack_timer.start()
	currentState = "Idle"

func _physics_process(delta: float) -> void:
	print(currentState)
	if hitbox.overlaps_body(player):
		player._deal_damage_to_player(2, self)
	match currentState:
		"Idle":
			_idle()
		"MarketCrash":
			_market_crash(delta)
		"ArrowAttack":
			_arrow_attack()
		"Ultimate":
			_ultimate_attack()

func _idle() -> void:
	velocity = Vector2.ZERO

func _market_crash(delta: float) -> void:
	var selected_screen = small_screens.pick_random()
	selected_screen.velocity.y += FALL_SPEED * delta
	if selected_screen.is_on_floor():
		_create_shockwaves(selected_screen.global_position)
		await get_tree().create_timer(0.5).timeout
		_return_to_ceiling(selected_screen)
	selected_screen.move_and_slide()

func _return_to_ceiling(screen) -> void:
	while screen.global_position.y > original_position.y:
		screen.global_position.y -= RETURN_SPEED * get_process_delta_time()
	currentState = "Idle"
	attack_timer.start()

func _create_shockwaves(position: Vector2) -> void:
	var shockwave_left = stomp_projectile.instantiate()
	shockwave_left.global_position = position + Vector2(-50, 0)
	shockwave_left.direction = Vector2.LEFT
	get_parent().add_child(shockwave_left)

	var shockwave_right = stomp_projectile.instantiate()
	shockwave_right.global_position = position + Vector2(50, 0)
	shockwave_right.direction = Vector2.RIGHT
	get_parent().add_child(shockwave_right)

func _arrow_attack() -> void:
	#for i in range(5):
		#var arrow_left = arrow_projectile.instantiate()
		#arrow_left.global_position = global_position + Vector2(-200, randf_range(-50, 50))
		#arrow_left.velocity = Vector2(ARROW_SPEED, sin(randf() * PI) * 50)
		#get_parent().add_child(arrow_left)
#
		#var arrow_right = arrow_projectile.instantiate()
		#arrow_right.global_position = global_position + Vector2(200, randf_range(-50, 50))
		#arrow_right.velocity = Vector2(-ARROW_SPEED, sin(randf() * PI) * 50)
		#get_parent().add_child(arrow_right)
	#await get_tree().create_timer(2.0).timeout
	#currentState = "Idle"
	attack_timer.start()

func _ultimate_attack() -> void:
	#for i in range(5):
		#await get_tree().create_timer(0.5).timeout
		#var explosion = explosion_projectile.instantiate()
		#explosion.global_position = global_position + Vector2(randf_range(-100, 100), randf_range(-50, 50))
		#get_parent().add_child(explosion)
	#await get_tree().create_timer(3.0).timeout
	#currentState = "Idle"
	attack_timer.start()

func _on_attack_timer_timeout() -> void:
	var attack_choice = randi() % 6
	match attack_choice:
		0, 1, 2:
			currentState = "MarketCrash"
		3, 4:
			currentState = "ArrowAttack"
		5:
			currentState = "Ultimate"
	print(currentState)

func _deal_damage(damage: int) -> void:
	health -= damage
	if health <= 0:
		_die()

func _die() -> void:
	dead.emit()
	queue_free()
