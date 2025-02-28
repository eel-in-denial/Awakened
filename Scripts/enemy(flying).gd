extends CharacterBody2D

const SPEED = 150.0
var speed = SPEED
const CHARGESPEED = 250.0
var health = 3
@onready var hitbox: Area2D = $Hitbox
var currentState := "Patrol"
var currentTarget: Marker2D
var detectionRange := 150.0

var pointA : Marker2D
var pointB : Marker2D
var player: Node2D

func _ready() -> void:
	player = get_node("../Player")
	pointA = get_node("../PatrolPositionA2")
	pointB = get_node("../PatrolPositionB2")
	if pointA:
		currentTarget = pointA
	pass

func _physics_process(delta: float) -> void:
	# Check for collisions
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
	
		if body is Player:
			body._deal_damage_to_player(1, global_position)
	
	_detect_player()
	
	if currentState == "Patrol":
		_patrol(delta)
	
	elif currentState == "Charge":
		_charge(delta)
	
func _patrol(delta: float) -> void:
	var to_target: Vector2 = currentTarget.global_position - global_position
	var step_distance: float = speed
	
	#print("Before move: global_position =", global_position, " Distance =", to_target.length())
	
	if to_target.length() <= step_distance * 0.05:
		currentTarget = pointB if (currentTarget == pointA) else pointA
	else:
		speed = SPEED
	var direction: Vector2 = to_target.normalized()
	velocity = direction * speed
	move_and_slide()
		
	#var direction: Vector2 = (currentTarget.global_position - global_position).normalized()
	#velocity = direction * speed
	#move_and_slide()
#
	#if global_position.distance_to(currentTarget.global_position) < 10.0:
		#currentTarget = pointB if (currentTarget == pointA) else pointA

func _charge(delta: float) -> void:
	var direction: Vector2 = (player.global_position - global_position).normalized()
	velocity = direction * CHARGESPEED
	move_and_slide()

func _detect_player() -> void:
	if global_position.distance_to(player.global_position) <= detectionRange:
		currentState = "Charge"

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
