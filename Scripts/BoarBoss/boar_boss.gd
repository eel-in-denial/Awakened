extends CharacterBody2D

const SPEED = 200.0
const CHARGESPEED = 500.0
const JUMP_FORCE = -400.0

var health = 40
@onready var hitbox: Area2D = $Hitbox
@onready var attack_timer: Timer = $AttackTimer
@onready var charge_timer: Timer = $ChargeTimer
@onready var ultimate_timer: Timer = $UltimateTimer
@onready var stomp_projectile = preload("res://Scenes/BoarBoss/stomp_projectile.tscn")

var has_landed = false

@export var player: Node2D

var currentState : String
var direction: int = -1 

func _ready() -> void:
	_start_fight()

func _start_fight() -> void:
	await get_tree().create_timer(2.0).timeout 
	currentState = "Start"
	await get_tree().create_timer(5.0).timeout 
	attack_timer.wait_time = 3.0
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	attack_timer.start()
	ultimate_timer.wait_time = 7.0
	ultimate_timer.timeout.connect(_on_ultimate_timer_timeout)
	
	currentState = "Patrol"

func _physics_process(delta: float) -> void:
	match currentState:
		"Start":
			_start(delta)
		"Patrol":
			_patrol(delta)
		"Charge":
			_charge(delta)
		"GroundPound":
			_ground_pound(delta)
		"Falling":
			_ground_pound(delta)
		"Ultimate":
			_ultimate(delta)

func _start(delta:float) -> void:
	velocity += get_gravity() * delta
	move_and_slide()
	
func _patrol(delta: float) -> void:
	velocity.x = direction * SPEED 
	if not is_on_floor():
		velocity += get_gravity() * delta
	print(velocity)
	move_and_slide()
	if is_on_wall():
		direction *= -1 

func _charge(delta: float) -> void:
	await get_tree().create_timer(2.0).timeout  # Charge delay before dashing
	var collision = move_and_collide(velocity * delta)
	if collision:
		direction *= -1 
		attack_timer.start(3.0)
		velocity = Vector2.ZERO
		currentState = "Patrol"

func _ground_pound(delta: float) -> void:
	attack_timer.stop()
	velocity.x = 0

	if currentState == "GroundPound":
		if is_on_floor():
			await get_tree().create_timer(0.5).timeout
			velocity.y = JUMP_FORCE  # Jump
			currentState = "Falling"  # Transition to Falling state
			has_landed = false  # Reset landing flag

	elif currentState == "Falling":
		velocity.y += get_gravity().y * delta  # Apply gravity naturally
		if is_on_floor() and not has_landed:
			velocity = Vector2.ZERO
			# Spawn projectiles only once per landing
			_projectile(Vector2.LEFT)
			_projectile(Vector2.RIGHT)
			has_landed = true  # Ensure projectiles are only fired once per landing
			await get_tree().create_timer(1.5).timeout  # Shockwave delay
			currentState = "Patrol"
			attack_timer.start(3.0)


	move_and_slide()

func _projectile(direction: Vector2) -> void:
	var projectile = stomp_projectile.instantiate()
	projectile.global_position = global_position + Vector2(0, 50)
	projectile.direction = direction
	get_parent().add_child(projectile)
	
func _ultimate(delta: float) -> void:
	attack_timer.stop()
	for _i in range(3):
		await get_tree().create_timer(0.6).timeout
		velocity.x = direction * CHARGESPEED
		move_and_slide()
	currentState = "Patrol"
	attack_timer.start(3.0)
	ultimate_timer.stop()

func _on_attack_timer_timeout() -> void:
	var attack_choice = randi() % 6
	match attack_choice:
		0, 1, 2:
			currentState = "Charge"
			velocity.x = (player.global_position - global_position).normalized().x * CHARGESPEED
		3, 4:
			currentState = "GroundPound"
		5:
			currentState = "Ultimate"
			ultimate_timer.start()
	print(currentState)

func _on_ultimate_timer_timeout() -> void:
	currentState = "Patrol"
	attack_timer.start(3.0)
	ultimate_timer.stop()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Player:
		body._deal_damage_to_player(1, global_position)

func _deal_damage(damage: int) -> void:
	health -= damage
	if health <= 0:
		_die()

func _die() -> void:
	queue_free()
