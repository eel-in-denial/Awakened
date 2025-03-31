extends CharacterBody2D

const SPEED = 150.0
var speed = SPEED
const CHARGESPEED = 300.0
const RECOVERY_SPEED = 180.0
var health = 3
@onready var hitbox: Area2D = $Hitbox
var currentState := "Patrol"
var currentTarget: Marker2D
var detectionRange := 150.0

@export var pointA : Marker2D
@export var pointB : Marker2D
@onready var player = Global.player

var dash_direction: Vector2 = Vector2.ZERO
var dash_initiated: bool = false

func _ready() -> void:
	if pointA:
		currentTarget = pointA

func _physics_process(delta: float) -> void:
	#print(currentState)
	if hitbox.overlaps_body(player):
		player._deal_damage_to_player(1, self)
		dash_direction = Vector2.ZERO
		dash_initiated = false
		currentState = "Recovery"
	match currentState:
		"Patrol":
			_patrol(delta)
		"Detected":
			_detected(delta)
		"Charge":
			_charge(delta)
		"Recovery":
			_recover(delta)
		"Knockback":
			_knockback(delta)

func _patrol(delta: float) -> void:
	var to_target: Vector2 = currentTarget.global_position - global_position
	var step_distance: float = speed
	
	if to_target.length() <= step_distance * 0.05:
		currentTarget = pointB if (currentTarget == pointA) else pointA
	else:
		speed = SPEED
	var direction: Vector2 = to_target.normalized()
	velocity = direction * SPEED
	_detect_player()
	move_and_slide()

func _detect_player() -> void:
	if global_position.distance_to(player.global_position) <= detectionRange:
		if currentState != "Detected" and currentState != "Charge":
			currentState = "Detected"
	
func _detected(delta: float) -> void:
	if not dash_initiated:
		dash_initiated = true
		velocity = Vector2.ZERO
		await get_tree().create_timer(2.0).timeout  
		if global_position.distance_to(player.global_position) <= 300:
			dash_direction = (player.global_position - global_position).normalized()
			velocity = dash_direction * CHARGESPEED
			currentState = "Charge"
		else:
			currentState = "Patrol"

func _charge(delta: float) -> void:
	move_and_slide()
	if is_on_surface():
		velocity = (dash_direction * -1) * speed
		await get_tree().create_timer(1.0).timeout  
		dash_direction = Vector2.ZERO
		dash_initiated = false
		currentState = "Patrol"

func _recover(delta: float) -> void:
	var direction: Vector2 = (global_position - player.global_position).normalized()
	velocity = direction * RECOVERY_SPEED 
	move_and_slide()
	await get_tree().create_timer(0.7).timeout 
	currentState = "Patrol"

func set_knockback():
	currentState = "Knockback"
	
func _knockback(delta: float) -> void:
	var knockback_direction = (global_position - player.global_position).normalized()
	velocity = knockback_direction * 250  

	move_and_slide()
	
	await get_tree().create_timer(0.5).timeout 

	currentState = "Patrol"
	dash_direction = (player.global_position - global_position).normalized()
	velocity = dash_direction * CHARGESPEED

func _deal_damage(damage: int) -> void:
	health -= damage
	
	set_knockback()

	if health <= 0:
		_die()

func _die() -> void:
	queue_free()
	
func is_on_surface() -> bool:
	return is_on_ceiling() or is_on_floor() or is_on_wall()
