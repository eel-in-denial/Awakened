extends CharacterBody2D

var currentState := "Patrol"
var health = 3
@onready var hitbox: Area2D = $Hitbox
@onready var ledge_detector: RayCast2D = $LedgeDetector
@onready var animation = $AnimationPlayer
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
	player = Global.player
	
func _physics_process(delta):
	if hitbox.overlaps_body(player):
		player._deal_damage_to_player(1, self)
	#print(currentState)
	if currentState == "Knockback":
		_knockback(delta)
		return
		
	if currentState == "Patrol":
		patrol(delta)
		if _detect_player():
			currentState = "Charge"
			charge_timer = charge_duration
			dash_direction = Vector2(sign(player.global_position.x - global_position.x), 0)
			if dash_direction.x > 0:
				animation.play("stomp_right")
			else:
				animation.play("stomp_left")
			
	if currentState == "Charge":
		charge_timer -= delta
		if charge_timer <= 0:
			currentState = "Dash"
			if dash_direction.x > 0:
				animation.play("dash_right")
			else:
				animation.play("dash_left")
			# animation
				
	if currentState == "Dash":
		velocity.x = dash_direction.x * dash_speed
		velocity += get_gravity() * delta
		move_and_slide()
		
		if dash_complete():
			currentState = "Recovery"
			
	elif currentState == "Recovery":
		if abs(velocity.x) < recovery_threshold:
			currentState = "Patrol"
			if direction == 1:
				animation.play("walking_right")
			else:
				animation.play("walking_left")
			
		else:
			velocity.x = move_toward(velocity.x, 0, recovery_deceleration * delta)
		velocity += get_gravity() * delta
		move_and_slide()
			

func patrol(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	velocity.x = direction * patrol_speed
	move_and_slide()

	if ((not ledge_detector.is_colliding()) and should_turn) or is_on_wall():
		direction *= -1
		if direction == 1:
			animation.play("walking_right")
		else:
			animation.play("walking_left")
		should_turn = false
		await get_tree().create_timer(0.2).timeout
		should_turn = true
		
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		
		if body is Player:
			body._deal_damage_to_player(1, global_position)

func _detect_player() -> bool:
	if global_position.distance_to(player.global_position) <= detectionRange and abs(global_position.y - player.global_position.y) <= 80.0:
		return true
	return false

func dash_complete() -> bool:
	if is_on_wall():
		return true
	if not _detect_player():
		return true
	return false
	
func set_knockback():
	var knockback_direction = sign(global_position.x - player.global_position.x)
	var knockback_velocity = Vector2(knockback_direction * 150, -250)
	velocity = knockback_velocity
	currentState = "Knockback"
	
func _knockback(delta):
	velocity += get_gravity() * delta 
	move_and_slide()
	if is_on_floor():
		currentState = "Patrol"
		
func _deal_damage(damage: int) -> void:
	health -= damage
	velocity.y = -200
	
	set_knockback()
	
	if health <= 0:
		_die()

func _die() -> void:
		queue_free()
