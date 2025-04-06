extends CharacterBody2D

const FALL_SPEED = 400.0
const RETURN_SPEED = 300.0
const ARROW_SPEED = 250.0
const EXPLOSION_DELAY = 1.0
const SNAP_THRESHOLD = 10.0

var health = 50
@onready var hitbox: Area2D = $Hitbox
@onready var attack_timer: Timer = $AttackTimer
@onready var player = Global.player
@onready var stomp_projectile = preload("res://Scenes/BoarBoss/stomp_projectile.tscn")
@onready var arrow_projectile = preload("res://Scenes/StockBoss/arrow.tscn")
@onready var explosion_projectile = preload("res://Scenes/StockBoss/explode_coin.tscn")
@onready var small_screens = [$SmallScreen1, $SmallScreen2, $SmallScreen3, $SmallScreen4]
var selected_screen;

var currentState : String
var original_positions = {} 
var ultimate_started = false
var has_fired_projectile = false
var arrow_direction_up = true 

signal dead

func _ready() -> void:
	for screen in small_screens:
		original_positions[screen] = screen.global_position
	_start_fight()

func _start_fight() -> void:
	await get_tree().create_timer(2.0).timeout
	attack_timer.wait_time = 3.0
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	attack_timer.start()
	currentState = "Idle"

func _physics_process(delta: float) -> void:
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
		"Return":
			_return_to_ceiling(selected_screen, delta)

func _idle() -> void:
	velocity = Vector2.ZERO

func _market_crash(delta: float) -> void:
	if selected_screen:
		selected_screen.velocity.y = FALL_SPEED
		selected_screen.move_and_slide()
		
		if selected_screen.is_on_floor() and not has_fired_projectile:
			has_fired_projectile = true
			_create_shockwaves(selected_screen.global_position)
			await get_tree().create_timer(1).timeout
			currentState = "Return"

func _return_to_ceiling(screen, delta) -> void:
	if screen:
		screen.velocity.y -= RETURN_SPEED * delta
		if abs(screen.global_position.y - original_positions[screen].y) <= SNAP_THRESHOLD:
			screen.velocity = Vector2.ZERO
			screen.global_position = original_positions[screen]
			currentState = "Idle"
			has_fired_projectile = false
			attack_timer.start()
		screen.move_and_slide()

func _create_shockwaves(position: Vector2) -> void:
	var shockwave_left = stomp_projectile.instantiate()
	shockwave_left.global_position = position + Vector2(0, -10)
	shockwave_left.direction = Vector2.LEFT
	get_parent().add_child(shockwave_left)

	var shockwave_right = stomp_projectile.instantiate()
	shockwave_right.global_position = position + Vector2(0, -10)
	shockwave_right.direction = Vector2.RIGHT
	get_parent().add_child(shockwave_right)
	
func _arrow_attack() -> void:
	if not has_fired_projectile:
		has_fired_projectile = true
		for i in range(2):
			var arrow_left = arrow_projectile.instantiate()
			arrow_left.global_position = global_position + Vector2(-500, randf_range(0, 200))
			arrow_left.direction = Vector2(2, 1).normalized()
			arrow_left.boss = self                        
			get_parent().add_child(arrow_left)

			var arrow_right = arrow_projectile.instantiate()
			arrow_right.global_position = global_position + Vector2(500, randf_range(0, 200))
			arrow_right.direction = Vector2(-2, - 1).normalized()
			arrow_right.boss = self
			get_parent().add_child(arrow_right)
		await get_tree().create_timer(2.0).timeout
		currentState = "Idle"
		attack_timer.start()

func _ultimate_attack() -> void:
	attack_timer.stop()  
	_spawn_ultimate_projectiles()
	currentState = "Idle"
	attack_timer.start()  

func _spawn_ultimate_projectiles():
	var top_left = global_position + Vector2(-200, -50) 
	var top_right = global_position + Vector2(200, -50)  
	
	for i in range(5): 		
		var angle = 70 + i * 10
		var projectile_left = explosion_projectile.instantiate()
		projectile_left.global_position = top_left + Vector2(randf_range(-50, 20), randf_range(-50, 40))
		projectile_left.direction = Vector2(cos(deg_to_rad(angle)), sin(deg_to_rad(angle))).normalized()
		get_parent().add_child(projectile_left)
		projectile_left.boss = self

		var projectile_right = explosion_projectile.instantiate()
		projectile_right.global_position = top_right + Vector2(randf_range(-50, 50), randf_range(-50, 40))
		projectile_right.direction = Vector2(cos(deg_to_rad(angle)), sin(deg_to_rad(angle))).normalized()
		get_parent().add_child(projectile_right)
		projectile_right.boss = self

	await get_tree().create_timer(EXPLOSION_DELAY).timeout
	currentState = "Idle" 
	attack_timer.start()

func _on_attack_timer_timeout() -> void:
	var attack_choice = randi() % 6
	has_fired_projectile = false
	match attack_choice:
		0, 1, 2:
			currentState = "MarketCrash"
			selected_screen = small_screens.pick_random()
		3, 4:
			currentState = "ArrowAttack"
		5:
			currentState = "Ultimate"
	#print(currentState)

func _deal_damage(damage: int) -> void:
	health -= damage
	if health <= 0:
		_die()

func _die() -> void:
	dead.emit()
	queue_free()
