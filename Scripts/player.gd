extends CharacterBody2D


const ACCELERATION := 50.0
const DECELERATION := 50.0
const MAX_SPEED := 300.0
const JUMP_VELOCITY := -550.0
const gravity := Global.gravity
var direction := 0.0

func _ready() -> void:
	pass

func _movement(delta: float) -> void:
	# if direction inputs detected, add to velocity, if not deccelerate to 0
	direction = Input.get_axis("left", "right")
	if direction:
		velocity.x += direction * ACCELERATION * delta * 60
		velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	elif !direction and velocity.x:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta * 60)
		

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = 100
	
	
	_movement(delta)
	
	
	#does godot physics stuff
	move_and_slide()
