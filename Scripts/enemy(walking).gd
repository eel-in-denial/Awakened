extends CharacterBody2D

const SPEED = 150.0
var direction := 1
var health = 3
@onready var hitbox: Area2D = $Hitbox
@onready var ledge_detector: RayCast2D = $LedgeDetector
@onready var animation = $AnimationPlayer
var should_turn := true

var currentState := "Patrol"
var knockback_velocity := Vector2.ZERO 
var player: CharacterBody2D

func _ready() -> void:
	ledge_detector.enabled = true

func _physics_process(delta: float) -> void:
	print(currentState)
	if hitbox.overlaps_body(player):
		player._deal_damage_to_player(1, self)
		
	if currentState == "Knockback":
		_knockback(delta)
		return 

	if currentState == "Patrol":
		patrol(delta)

func patrol(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	velocity.x = direction * SPEED
	move_and_slide()

	if (not ledge_detector.is_colliding()) and should_turn:
		direction *= -1
		if direction == 1:
			animation.play("walk_right")
		else:
			animation.play("walk_left")
		should_turn = false
		await get_tree().create_timer(0.2).timeout
		should_turn = true

func _deal_damage(damage: int) -> void:
	health -= damage
	
	set_knockback()

	if health <= 0:
		_die()

func set_knockback():
	var knockback_direction = sign(global_position.x - player.global_position.x)
	knockback_velocity = Vector2(knockback_direction * 150, -250)
	velocity = knockback_velocity
	currentState = "Knockback"
	
func _knockback(delta):
	velocity += get_gravity() * delta 
	move_and_slide()

	if is_on_floor():
		currentState = "Patrol"

func _die() -> void:
	queue_free()
