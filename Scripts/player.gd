extends CharacterBody2D
class_name Player

enum States {IDLE, RUNNING, JUMPING, FALLING, DASH, WALLCLING}
var current_state: States = States.JUMPING: set = set_state
var prev_state: States

const JUMP_VELOCITY := -450.0
const gravity := Global.gravity
const SPEED := 300.0
const DASH_SPEED := 800.0
const DASH_DURATION := 15
var dash_time := 0
var direction := 0.0
var prev_velocity := 0.0
var moving := 0.0
var health := 10
var is_invincible : bool = false
var iframe_duration := 1.0
@onready var sword = $"Sword area"
@onready var sword_collision = $"Sword area/CollisionShape2D"
@onready var animation_player = $AnimationPlayer
@onready var damage_overlay = $damageOverlay
# node tree variables


func _ready() -> void:
	sword_collision.disabled = true
	

func _movement(delta: float) -> void:
	#sword.rotation = 90*Global.radians_conv*direction
	velocity.x = moving * SPEED * delta * 60
	#velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	
	#elif !direction and velocity.x:
		#velocity.x = move_toward(velocity.x, 0, DECELERATION * delta * 60)
	#else:
		#animation_player.play("idle")
		
func _attack() -> void:
	sword_collision.disabled = false
	
 
func _physics_process(delta: float) -> void:
	moving = Input.get_axis("left", "right")
	if moving:
		direction = moving
	if current_state in [States.JUMPING, States.FALLING]:
		velocity.y += gravity*delta
		if is_on_floor():
			set_state(States.IDLE)
	if current_state == States.JUMPING and (Input.is_action_just_released("jump") or velocity.y >= 0):
		set_state(States.FALLING)
	if current_state == States.RUNNING and not moving:
		set_state(States.IDLE)
	if Input.is_action_just_pressed("jump") and current_state in [States.IDLE, States.RUNNING]:
		set_state(States.JUMPING)
	if current_state == States.IDLE and moving:
		set_state(States.RUNNING)
	if Input.is_action_just_pressed("dash"):
		set_state(States.DASH)
	if current_state == States.DASH:
		dash_time -= 1
		if dash_time == 0:
			set_state(prev_state)
	
	# Add the gravity.


	#if Input.is_action_just_released("jump") and velocity.y < 0:
		#velocity.y = 100
	#if Input.is_action_just_pressed("attack"):
		#_attack()
	if current_state in [States.RUNNING, States.JUMPING, States.FALLING]:
		_movement(delta)
	
	
	#does godot physics stuff
	move_and_slide()
	print(States.keys()[current_state], direction)

func set_state(new_state: int) -> void:
	prev_state = current_state
	current_state = new_state
	match prev_state:
		States.DASH:
			if prev_velocity*direction <= 0:
				velocity.x = 0
			else:
				velocity.x = prev_velocity
			if new_state == States.JUMPING:
				set_state(States.FALLING)
				return
	match current_state:
		States.IDLE:
			velocity.x = 0
			animation_player.play("idle")
		States.RUNNING:
			if direction == 1:
				animation_player.play("walk_right")
			else:
				animation_player.play("walk_left")
		States.JUMPING:
			velocity.y = JUMP_VELOCITY
			if direction == 1:
				animation_player.play("jump_right")
			else:
				animation_player.play("jump_left")
		States.FALLING:
			velocity.y = 0
		States.DASH:
			prev_velocity = velocity.x
			velocity.x = direction * DASH_SPEED
			velocity.y = 0
			dash_time = DASH_DURATION

func _on_sword_area_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body._deal_damage(1)

func _on_sword_area_body_exited(body: Node2D) -> void:
	pass
	
func _trigger_iframes() -> void:
	is_invincible = true
	damage_overlay.visible = true
	await get_tree().create_timer(iframe_duration).timeout
	
	is_invincible = false
	damage_overlay.visible = false
	
func _take_knockback(position: Vector2, force: float = 1000.0) -> void:
	
	var knockback_direction = (global_position - position).normalized()
	knockback_direction.y *= 0.5  # Reduce upward knockback
	knockback_direction = knockback_direction.normalized()
	
	velocity += knockback_direction * force
	
func _deal_damage_to_player(damage: int, position: Vector2) -> void:
	if is_invincible:
		return
		
	health -= damage
	_take_knockback(position)
	
	if health <= 0:
		_die()
	else:
		_trigger_iframes()
	
func _die() -> void:
	queue_free()
