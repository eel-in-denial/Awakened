extends CharacterBody2D

var state := "Patrol"
var health = 3
@onready var hitbox: Area2D = $Hitbox
@onready var ledge_detector: RayCast2D = $LedgeDetector
var should_turn := true;

var patrol_speed = 100
var direction = 1
var dash_speed = 250

var charge_duration = 0.5
var charge_timer = 0.0

var detectionRange := 150.0

var dash_direction = Vector2.ZERO
var player : CharacterBody2D

var recovery_deceleration = 300.0  
var recovery_threshold = 0.1

func _ready() -> void:
	ledge_detector.enabled = true
	player = get_node("../Player")
	
func _physics_process(delta):
	#print(state)
	if state == "Patrol":
		patrol(delta)
		if _detect_player():
			state = "Charge"
			charge_timer = charge_duration
			dash_direction = Vector2(sign(player.global_position.x - global_position.x), 0)
			# animation/sound here.
			
	if state == "Charge":
		charge_timer -= delta
		if charge_timer <= 0:
			state = "Dash"
			# animation
				
	if state == "Dash":
		velocity.x = dash_direction.x * dash_speed
		velocity += get_gravity() * delta
		move_and_slide()
		
		if dash_complete():
			state = "Recovery"
			
	elif state == "Recovery":
		if abs(velocity.x) < recovery_threshold:
			state = "Patrol"
		else:
			velocity.x = move_toward(velocity.x, 0, recovery_deceleration * delta)
		velocity += get_gravity() * delta
		move_and_slide()
			
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		if body is Player:
			body._deal_damage_to_player(1, global_position)
	
	if is_on_wall():
		direction *= -1

func patrol(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	velocity.x = direction * patrol_speed
	move_and_slide()

	if (not ledge_detector.is_colliding()) and should_turn:
		direction *= -1
		should_turn = false
		await get_tree().create_timer(0.2).timeout
		should_turn = true
		
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		
		if body is Player:
			body._deal_damage_to_player(1, global_position)

func _detect_player() -> bool:
	if global_position.distance_to(player.global_position) <= detectionRange and abs(global_position.y - player.global_position.y) <= 20.0:
		return true
	return false

func dash_complete() -> bool:
	if is_on_wall():
		return true
	if not _detect_player():
		return true
	return false
	
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
