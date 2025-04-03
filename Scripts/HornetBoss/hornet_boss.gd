extends CharacterBody2D

var bounce_offset: float = 0.0
var bounce_direction: int = -1 
const BOUNCE_RANGE = 5.0 
const BOUNCE_SPEED = 30.0  
const Recovery_speed = 120

const IDLE_SPEED = 20.0
const DASH_SPEED = 600.0
const HEALTH = 30
var dash_direction

var health = HEALTH

@export var centerMarker: Marker2D
@export var hornet_main: Node2D
@onready var hitbox: Area2D = $Hitbox
@onready var attack_timer: Timer = $AttackTimer
@onready var ultimate_timer: Timer = $UltimateTimer
@onready var dash_timer: Timer = $DashTimer
@onready var collision: CollisionShape2D = $CollisionShape2D

@onready var hornet_projectile_scene = preload("res://Scenes/HornetBoss/hornet_boss_projectile.tscn")
@onready var small_hornet_scene = preload("res://Scenes/Enemies/StaticEnemy/enemy(static).tscn")

var currentState: String = "Idle"
var player: Node2D

func _ready() -> void:
	player = Global.player
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	

func _start_fight() -> void:
	global_position = centerMarker.global_position + Vector2(0, -400)
	currentState = "Spawn"
	
	dash_timer.wait_time = 2.0
	attack_timer.start(3.0)
	ultimate_timer.wait_time = 3.0
	ultimate_timer.timeout.connect(_on_ultimate_timer_timeout)

func _physics_process(delta: float) -> void:
	if hitbox.overlaps_body(player):
		player._deal_damage_to_player(2, self)
	match currentState:
		"Spawn":
			_spawn(delta)
		"Idle":
			_idle(delta)
		"Dash":
			_dash(delta)
		"Projectile":
			_projectile(delta)
		"Ultimate":
			_ultimate(delta)
		"Recovery":
			_recovery(delta)

func _spawn(delta: float) -> void:
	var target = centerMarker.global_position
	global_position = global_position.move_toward(target, Recovery_speed * delta)
	if global_position.distance_to(target) < 2:
		global_position = target
		currentState = "Idle"
		await get_tree().create_timer(3.0).timeout  
		attack_timer.start(3.0)

func _idle(delta: float) -> void:
	print(attack_timer.time_left)
	bounce_offset += bounce_direction * BOUNCE_SPEED * delta
	if bounce_offset <= -BOUNCE_RANGE or bounce_offset >= BOUNCE_RANGE:
		bounce_direction *= -1  
	global_position.y = global_position.y + bounce_offset


func _dash(delta: float) -> void:
	print("dashing")
	collision.disabled = true
	attack_timer.stop()
	global_position += dash_direction * DASH_SPEED * delta
	
func _on_dash_timer_timeout() -> void:
	global_position = centerMarker.position + Vector2(0, -200)
	currentState = "Recovery"
	dash_timer.stop()
	
func _recovery(delta: float) -> void:
	print("recovering")
	var direction = (centerMarker.global_position - global_position).normalized()
	global_position += direction * Recovery_speed * delta
	var to_target: Vector2 = centerMarker.global_position - global_position
	if to_target.length() <= 10:
		currentState = "Idle"
		collision.disabled = false
		attack_timer.start()


func _projectile(delta: float) -> void:
	var base_dir = (player.global_position - global_position).normalized()
	var angle_offsets = [deg_to_rad(-90), deg_to_rad(-45), 0, deg_to_rad(45), deg_to_rad(90)]
	
	for angle in angle_offsets:
		var projectile = hornet_projectile_scene.instantiate()
		projectile.global_position = global_position
		projectile.direction = base_dir.rotated(angle)
		get_tree().get_root().add_child(projectile)
		projectile.owner = self
		
	currentState = "Idle"
	attack_timer.start(3.0)

func _ultimate(delta: float) -> void:
	var spawn_count = 3
	for i in range(spawn_count):
		var spawn_offset = Vector2(randf_range(-200, 200), randf_range(-200, 200))
		var small_hornet = small_hornet_scene.instantiate()
		small_hornet.player = player
		small_hornet.global_position = global_position + spawn_offset
		get_parent().add_child(small_hornet)
		small_hornet.current_state = "Chasing"
	currentState = "Idle"
	attack_timer.start()

func _on_attack_timer_timeout() -> void:
	var attack_choice = randi() % 10
	if attack_choice < 4:	
		dash_timer.start()
		dash_direction = (player.global_position - global_position).normalized()
		currentState = "Dash"
	elif attack_choice < 8:
		currentState = "Projectile"
	else:
		currentState = "Ultimate"

func _on_ultimate_timer_timeout() -> void:
	currentState = "Idle"
	attack_timer.start()

func _deal_damage(damage: int) -> void:
	health -= damage
	velocity.y = -200
	if health <= 0:
		_die()

func _die() -> void:
	hornet_main.dead.emit()
	queue_free()
