extends CharacterBody2D

const SPEED = 200.0
const CHARGESPEED = 500.0
const JUMP_FORCE = -400.0

var health = 40
@onready var hitbox: Area2D = $Hitbox
@onready var attack_timer: Timer = $AttackTimer
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var stomp_projectile = preload("res://Scenes/BoarBoss/stomp_projectile.tscn")

var has_landed = false

@onready var player = Global.player

var currentState : String
var direction: int = -1 

var ultimate_started = false
var ultimate_state = ""
var count: int

signal dead

func _ready() -> void:
	pass
	

func _start_fight() -> void:
	await get_tree().create_timer(2.0).timeout 
	currentState = "Start"
	await get_tree().create_timer(5.0).timeout 
	attack_timer.wait_time = 3.0
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	attack_timer.start()
	
	currentState = "Patrol"
	if direction == 1:
		animation.play("walk_right")
	else:
		animation.play("walk_left")

func _physics_process(delta: float) -> void:
	#print(velocity) 
	#print(get_real_velocity())
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
	move_and_slide()
	if is_on_wall():
		print("patrol bounce")
		direction *= -1 
		if direction == 1:
			animation.play("walk_right")
		else:
			animation.play("walk_left")
		
		
var dash_in_progress: bool = false
var dash_started: bool = false

func _charge(delta: float) -> void:
	if not dash_in_progress:
		dash_in_progress = true
		charge_routine()

	if dash_started:
		if is_on_wall():
			print("dash bounce")
			direction *= -1
			attack_timer.start(3.0)
			velocity = Vector2.ZERO
			currentState = "Patrol"
			dash_in_progress = false
			dash_started = false
		move_and_slide()


func charge_routine() -> void:
	await get_tree().create_timer(2.0).timeout
	dash_started = true
	if (player.global_position - global_position).normalized().x > 0:
		animation.play("dash_right")
	else:
		animation.play("dash_left")


func _ground_pound(delta: float) -> void:
	attack_timer.stop()
	velocity.x = 0

	if currentState == "GroundPound":
		if is_on_floor():
			await get_tree().create_timer(0.5).timeout
			velocity.y = JUMP_FORCE 
			currentState = "Falling"  
			has_landed = false  

	elif currentState == "Falling":
		velocity.y += get_gravity().y * delta
		if is_on_floor() and not has_landed:
			velocity = Vector2.ZERO
			_projectile(Vector2.LEFT)
			_projectile(Vector2.RIGHT)
			has_landed = true
			await get_tree().create_timer(1.5).timeout 
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
	velocity.x = 0
	if ultimate_state == "Jump":
		if is_on_floor():
			await get_tree().create_timer(0.2).timeout
			velocity.y = JUMP_FORCE
			ultimate_state = "Falling" 
			has_landed = false 
	elif ultimate_state == "Falling":
		velocity.y += get_gravity().y * delta  
		if is_on_floor() and not has_landed:
			velocity = Vector2.ZERO
			_projectile(Vector2.LEFT)
			_projectile(Vector2.RIGHT)
			has_landed = true 
			count += 1
			if is_on_floor() and count < 3:
				ultimate_state = "Jump"
			elif count == 3:
				await get_tree().create_timer(3).timeout
				currentState = "Patrol"
				attack_timer.start()
	move_and_slide()
	
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
			count = 0
			ultimate_state = "Jump"
	print(currentState)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Player:
		body._deal_damage_to_player(1, global_position)

func _deal_damage(damage: int) -> void:
	health -= damage
	if health <= 0:
		_die()

func _die() -> void:
	dead.emit()
	queue_free()


func _on_arena_door_2_boss_start() -> void:
	_start_fight()
