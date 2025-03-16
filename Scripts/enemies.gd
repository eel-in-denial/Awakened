extends CharacterBody2D

const SPEED = 150.0
var direction := 1
var health = 3
@onready var hitbox: Area2D = $Hitbox
@onready var ledge_detector: RayCast2D = $LedgeDetector
var should_turn := true;

func _ready() -> void:
	ledge_detector.enabled = true

func _physics_process(delta: float) -> void:
	# Apply gravity if not on the floor
	if not is_on_floor():
		velocity += get_gravity() * delta

	velocity.x = direction * SPEED
	move_and_slide()

	if (not ledge_detector.is_colliding()) and should_turn:
		direction *= -1
		should_turn = false
		await get_tree().create_timer(0.2).timeout
		should_turn = true
	
	if is_on_wall():
		direction *= -1
		
	# Check for collisions
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		
		if body is Player:
			body._deal_damage_to_player(1, global_position)
		#elif body.is_in_group("Walls") or body.is_in_group("Enemies"):
			#direction *= -1
	
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
	
	
