extends CharacterBody2D
class_name Player

enum States {IDLE, RUNNING, JUMPING, FALLING, DASH, WALLCLING, KNOCKBACK}
var current_state: States = States.JUMPING: set = set_state
var prev_state: States

const JUMP_VELOCITY := -450.0
const gravity := Global.gravity
const SPEED := 300.0
const DASH_SPEED := 800.0
const DASH_DURATION := 0.16
const HURT_DURATION := 1.0
const KNOCKBACK_HEIGHT := -250
var dash_time := 0.0
var iframe_timer := 0.0
var is_invinsible := false
var direction := 0.0
var knock_direction := 0.0
var prev_velocity := 0.0
var moving := 0.0
var health := 10
@onready var sword = $"Sword area"
@onready var sword_collision = $"Sword area/CollisionShape2D"
@onready var damage_overlay = $damageOverlay
@onready var animation_tree = $AnimationTree
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
	match current_state:
		States.IDLE:
			if Input.is_action_just_pressed("jump"):
				set_state(States.JUMPING)
			elif moving:
				set_state(States.RUNNING)
			elif Input.is_action_just_pressed("dash"):
				set_state(States.DASH)
			elif not is_on_floor():
				set_state(States.FALLING)
		States.RUNNING:
			_movement(delta)
			if Input.is_action_just_pressed("jump"):
				set_state(States.JUMPING)
			elif not moving:
				set_state(States.IDLE)
			elif Input.is_action_just_pressed("dash"):
				set_state(States.DASH)
			elif not is_on_floor():
				set_state(States.FALLING)
		States.JUMPING:
			velocity.y += gravity*delta
			_movement(delta)
			if Input.is_action_just_released("jump") or velocity.y >= 0:
				set_state(States.FALLING)
			elif Input.is_action_just_pressed("dash"):
				set_state(States.DASH)
			elif is_on_floor():
				set_state(States.IDLE)
		States.FALLING:
			velocity.y += gravity*delta
			_movement(delta)
			if Input.is_action_just_pressed("dash"):
				set_state(States.DASH)
			elif is_on_floor():
				set_state(States.IDLE)
		States.DASH:
			dash_time -= delta
			if dash_time <= 0:
				set_state(prev_state)
		States.KNOCKBACK:
			if is_on_floor() and velocity.y != KNOCKBACK_HEIGHT:
				set_state(States.IDLE)
			velocity.y += gravity*delta
	if is_invinsible:
		iframe_timer -= delta
		if iframe_timer <= 0.0:
			is_invinsible = false
	move_and_slide()
	print(States.keys()[current_state], velocity)

func _process(delta: float) -> void:
	animation_tree.set("parameters/Run/blend_position", direction)
	animation_tree.set("parameters/Idle/blend_position", direction)
	animation_tree.set("parameters/Jump/blend_position", direction)

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
		States.RUNNING:
			pass
		States.JUMPING:
			velocity.y = JUMP_VELOCITY
		States.FALLING:
			velocity.y = 0
		States.DASH:
			prev_velocity = velocity.x
			velocity.x = direction * DASH_SPEED
			velocity.y = 0
			dash_time = DASH_DURATION
		States.KNOCKBACK:
			is_invinsible = true
			velocity.x = knock_direction*250
			velocity.y = KNOCKBACK_HEIGHT
			iframe_timer = HURT_DURATION
			var tween: Tween = create_tween().set_loops(HURT_DURATION/0.5)
			tween.tween_property(self, "modulate:v", 1, 0.5).from(0)
			

func _on_sword_area_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body._deal_damage(1)

func _on_sword_area_body_exited(body: Node2D) -> void:
	pass
	
	
func _deal_damage_to_player(damage: int, enemy_position: Vector2) -> void:
	if is_invinsible:
		return
		
	health -= damage
	if global_position.x < enemy_position.x:
		knock_direction = -1
	else:
		knock_direction = 1
	set_state(States.KNOCKBACK)
	
	
	if health <= 0:
		_die()
	
func _die() -> void:
	queue_free()
