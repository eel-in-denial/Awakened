extends CharacterBody2D
class_name Bosses

const SPEED = 300.0
const CHARGESPEED = 600.0

var health = 50
@onready var hitbox: Area2D = $Hitbox
@onready var attack_timer: Timer = $AttackTimer
@onready var shriek_projectile = preload("res://Scenes/GooseBoss/shriek.tscn")
@onready var feather_projectile = preload("res://Scenes/GooseBoss/featherProjectile.tscn")
@onready var ultimate_timer: Timer = $UltimateTimer
var currentState : String
var currentTarget: Marker2D

@export var pointA : Marker2D
@export var pointB : Marker2D
@export var leftBound : Marker2D
@export var rightBound : Marker2D
@export var centerMarker: Marker2D
@onready var player = Global.player
@export var goose_main: Node2D
var last_spawn_x

var charge_timer := 0.6

var rain_accumulator := 0.0

func _ready() -> void:
	visible = false
	if pointA:
		currentTarget = pointA
		

func _start_fight() -> void:
	visible = true
	#play animation
	await get_tree().create_timer(1.0).timeout  
	currentState = "Patrol"
	
	attack_timer.wait_time = 3.0
	attack_timer.start()
	
	ultimate_timer.wait_time = 7.0 
	ultimate_timer.timeout.connect(_on_ultimate_timer_timeout)

func _physics_process(delta: float) -> void:
	if hitbox.overlaps_body(player):
		player._deal_damage_to_player(2, self)
	match currentState:
		"Patrol":
			_patrol(delta)
		"Charge":
			_charge(delta)
		"Recovery":
			_recovery(delta)
		"Projectile":
			_projectile(delta)
		"Ultimate":
			_ultimate(delta)
	
func _patrol(delta: float) -> void:
	var to_target: Vector2 = currentTarget.global_position - global_position

	#print("Before move: global_position =", global_position, " Distance =", to_target.length())
	
	if to_target.length() <= SPEED * 0.05:
		currentTarget = pointB if (currentTarget == pointA) else pointA

	var direction: Vector2 = to_target.normalized()
	velocity = direction * SPEED
	move_and_collide(velocity * delta)
		
	#var direction: Vector2 = (currentTarget.global_position - global_position).normalized()
	#velocity = direction * speed
	#move_and_slide()
#
	#if global_position.distance_to(currentTarget.global_position) < 10.0:
		#currentTarget = pointB if (currentTarget == pointA) else pointA

var timed = false

func _charge(delta: float) -> void:
	print(currentState)
	while charge_timer > 0:
		charge_timer -= delta
		return
	if not timed:
		timed = true
		velocity = (player.global_position - global_position).normalized() * CHARGESPEED
	move_and_slide()
	if (is_on_floor() or is_on_wall()):
		currentState = "Recovery"  
		print(currentState)
		velocity = Vector2(0, -300) 
		await get_tree().create_timer(0.5).timeout  
		currentState = "Patrol"
		attack_timer.start(3.0)
		charge_timer = 0.6
		timed = false
		
func _recovery(delta: float) -> void:
	velocity.y = -300
	move_and_slide()

	if global_position.y < centerMarker.global_position.y - 100:  
		currentState = "Patrol"
		attack_timer.start(3.0)

func _projectile(delta: float) -> void:
	while charge_timer > 0:
		charge_timer -= delta
		return
	var projectile: Node2D = shriek_projectile.instantiate()
	projectile.global_position = global_position
	projectile.direction = (player.global_position - global_position).normalized()
	projectile.look_at(player.global_position)
	get_tree().get_root().add_child(projectile)
	currentState = "Patrol"
	attack_timer.start(3.0)
	charge_timer = 0.6
		
func _ultimate(delta: float) -> void:
	attack_timer.stop()
	
	if global_position.distance_to(centerMarker.global_position) > 10:
		var direction = (centerMarker.global_position - global_position).normalized()
		velocity = direction * SPEED
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		_rain_projectiles(delta)
		
func _rain_projectiles(delta: float) -> void:
	rain_accumulator += delta
	while rain_accumulator >= 0.15:
		rain_accumulator -= 0.15
		
		var projectile = feather_projectile.instantiate()

		var min_x = leftBound.global_position.x
		var max_x = rightBound.global_position.x

		var spawn_y = leftBound.global_position.y - 20  
		
		var spawn_x = randf_range(min_x, max_x)
		if abs(spawn_x - last_spawn_x) < 50:
			spawn_x = last_spawn_x + (50 if spawn_x > last_spawn_x else -50)
		
		projectile.global_position = Vector2(spawn_x, spawn_y)
		last_spawn_x = spawn_x 

		projectile.global_position = Vector2(randf_range(min_x, max_x), spawn_y)
		projectile.direction = Vector2(0.1, 1)
		get_tree().get_root().add_child(projectile)
		
func _on_ultimate_timer_timeout() -> void:
	currentState = "Patrol"
	attack_timer.start(3.0)
	ultimate_timer.stop()
	rain_accumulator = 0.0

func _on_attack_timer_timeout() -> void:
	var attack_choice = randi() % 11
	match attack_choice:
		0, 1, 2, 3, 4:
			currentState = "Charge"
		5, 6, 7, 8, 9:
			currentState = "Projectile"
		10:
			currentState = "Ultimate"
			last_spawn_x = leftBound.global_position.x - 100
			ultimate_timer.start()
	print(currentState)

func _deal_damage(damage: int) -> void:
	health -= damage
	#velocity.y = -200
	var tween: Tween = create_tween().set_loops(0.5*2)
	tween.tween_property(self, "modulate:v", 1, 0.5).from(0)
	if health <= 0:
		_die()

func _die() -> void:
	goose_main.dead.emit()
	queue_free()
