extends CharacterBody2D

const SPEED = 150.0
var direction := 1
var health = 3
@onready var hitbox: Area2D = $Hitbox
@onready var ledge_detector: RayCast2D = $LedgeDetector
var should_turn := true

var state := "Patrol"
var knockback_velocity := Vector2.ZERO  # Stores knockback speed
var player: CharacterBody2D

func _ready() -> void:
	ledge_detector.enabled = true
	player = get_node("../Player")

func _physics_process(delta: float) -> void:
	if state == "Knockback":
		apply_knockback(delta)
		return  # Prevents other states from running

	if state == "Patrol":
		patrol(delta)

	# Check for collisions with the player
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		
		if body is Player:
			body._deal_damage_to_player(1, global_position)

func patrol(delta):
	# Apply gravity if not on the floor
	if not is_on_floor():
		velocity += get_gravity() * delta

	velocity.x = direction * SPEED
	move_and_slide()

	# Turn around if near a ledge
	if (not ledge_detector.is_colliding()) and should_turn:
		direction *= -1
		should_turn = false
		await get_tree().create_timer(0.2).timeout
		should_turn = true
	
	if is_on_wall():
		direction *= -1

func _deal_damage(damage: int) -> void:
	health -= damage
	
	# Determine knockback direction (away from player)
	var knockback_direction = sign(global_position.x - player.global_position.x)
	knockback_velocity = Vector2(knockback_direction * 150, -250)  # Apply horizontal & vertical knockback
	velocity = knockback_velocity
	
	state = "Knockback"

	if health <= 0:
		_die()

func apply_knockback(delta):
	velocity += get_gravity() * delta  # Apply gravity to knockback
	move_and_slide()

	if is_on_floor():
		state = "Patrol"

func _on_enemy_body_contact(body: Node2D) -> void:
	if body is Player:
		body._deal_damage_to_player(1, global_position)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Player:
		body._deal_damage_to_player(1, global_position)

func _die() -> void:
	queue_free()
