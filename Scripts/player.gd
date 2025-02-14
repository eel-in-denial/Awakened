extends CharacterBody2D
class_name Player

enum States {IDLE, RUNNING, JUMPING, DASH, WALLCLING}
var current_state: States = States.IDLE: set = set_state

const ACCELERATION := 50.0
const DECELERATION := 50.0
const MAX_SPEED := 300.0
const JUMP_VELOCITY := -550.0
const gravity := Global.gravity
var direction := 0.0
@onready var sword = $"Sword area"
@onready var sword_collision = $"Sword area/CollisionShape2D"
@onready var animation_player = $AnimationPlayer
# node tree variables


func _ready() -> void:
	sword_collision.disabled = true
	

func _movement(delta: float) -> void:
	# if direction inputs detected, add to velocity, if not deccelerate to 0
	direction = Input.get_axis("left", "right")
	
	if direction:
		sword.rotation = 90*Global.radians_conv*direction
		velocity.x += direction * ACCELERATION * delta * 60
		velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
		if direction == 1 and animation_player.current_animation != "jump_left" and animation_player.current_animation != "jump_right":
			animation_player.play("walk_right")
		elif animation_player.current_animation != "jump_left" and animation_player.current_animation != "jump_right":
			animation_player.play("walk_left")
	elif !direction and velocity.x:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta * 60)
	else:
		animation_player.play("idle")
		
func _attack() -> void:
	sword_collision.disabled = false
	
 
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and current_state in [States.IDLE, States.RUNNING, States.WALLCLING]:
		set_state(States.JUMPING)
	if current_state == States.IDLE and Input:
		set_state(States.RUNNING)
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if direction == 1:
			animation_player.play("jump_right")
		else:
			animation_player.play("jump_left")
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = 100
	if Input.is_action_just_pressed("attack"):
		_attack()
	_movement(delta)
	
	#does godot physics stuff
	move_and_slide()
	print(current_state)

func set_state(new_state: int) -> void:
	current_state = new_state

func _on_sword_area_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.queue_free()

func _on_sword_area_body_exited(body: Node2D) -> void:
	pass
