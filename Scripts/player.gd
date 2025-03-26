class_name Player extends CharacterBody2D

enum States {IDLE, RUNNING, JUMPING, FALLING, DASH, WALLCLING, KNOCKBACK, PARRY}
enum Attack_States {IDLE, SLASH, SHOOT}
var current_state: States = States.JUMPING: set = set_state
var current_atk_state: Attack_States = Attack_States.SLASH: set = set_attack
var prev_state: States

var loaded = false

const JUMP_VELOCITY := -450.0
const gravity := Global.gravity
const ACCELERATION := 20.0
const DECELERATION := 5.0
const MAX_SPEED := 200.0
const DASH_SPEED := 800.0
const DASH_DURATION := 0.16
const HURT_DURATION := 1.0
const ATTACK_DURATION := 0.5
const KNOCKBACK_HEIGHT := -250.0
const PARRY_DURATION := 1.0
const MAX_HEALTH := 10.0
const MAX_ENERGY := 100.0

var dash_time := 0.0
var iframe_timer := 0.0
var attack_timer := 0.0
var parry_timer := 0.0
var corner_jump := false
var is_invincible := false
var direction := Vector2(1, 0)
var knock_direction := 0.0
var prev_velocity := 0.0
var moving := 0.0
var health := MAX_HEALTH
var energy := 0.0
var canMove = true

var camera_return_offset: Vector2 = Vector2(0, -20)
var camera_hold_duration: float = 0.0
var camera_pan_duration: float = 0.0
var centerMarker: Marker2D

@onready var sword = $"Sword area"
@onready var sword_collision = $"Sword area/CollisionShape2D"

@onready var parry_overlay = $ParryBox
@onready var leg_animation = $PlayerLegsAnim
@onready var body_animation = $PlayerBodyAnim
@export var UI: CanvasLayer
@onready var camera = $Camera2D 

func _ready() -> void:
	centerMarker = get_node("../CenterMarker")
	sword_collision.disabled = true
	Global.player = self
	loaded = true
	

func _movement(delta: float) -> void:
	#sword.rotation = 90*Global.radians_conv*direction
	velocity.x += moving * ACCELERATION * delta * 60
	
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	
	if not moving and velocity.x:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta * 60)
	#else:
		#animation_player.play("idle")
		
func _attack() -> void:
	sword_collision.disabled = false

func _parry(damage: int) -> void:
	energy += damage * 20
	parry_overlay.visible = false
	set_state(States.KNOCKBACK)
	is_invincible = true
	iframe_timer = HURT_DURATION
	UI.update()

func _physics_process(delta: float) -> void:
	moving = Input.get_axis("left", "right")
	if moving:
		direction.x = moving
	direction.y = Input.get_axis("up", "down")
	match current_state:
		States.IDLE:
			if Input.is_action_just_pressed("jump"):
				set_state(States.JUMPING)
			elif moving:
				set_state(States.RUNNING)
			elif Input.is_action_just_pressed("dash"):
				set_state(States.DASH)
			elif Input.is_action_just_pressed("parry"):
				set_state(States.PARRY)
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
			elif Input.is_action_just_pressed("parry"):
				set_state(States.PARRY)
			elif not is_on_floor():
				set_state(States.FALLING)
		States.JUMPING:
			velocity.y += gravity*delta
			_movement(delta)
			if Input.is_action_just_released("jump") or velocity.y >= 0:
				set_state(States.FALLING)
			elif Input.is_action_just_pressed("dash"):
				set_state(States.DASH)
			elif is_on_floor() and moving:
				set_state(States.RUNNING)
			elif Input.is_action_just_pressed("parry"):
				set_state(States.PARRY)
			elif is_on_floor():
				set_state(States.IDLE)
		States.FALLING:
			velocity.y += gravity*delta
			_movement(delta)
			if Input.is_action_just_pressed("dash"):
				set_state(States.DASH)
			elif is_on_floor() and moving:
				set_state(States.RUNNING)
			elif Input.is_action_just_pressed("parry"):
				set_state(States.PARRY)
			elif is_on_floor():
				set_state(States.IDLE)
			elif is_on_wall():
				set_state(States.WALLCLING)
		States.DASH:
			dash_time -= delta
			if dash_time <= 0:
				set_state(prev_state)
		States.KNOCKBACK:
			if is_on_floor() and velocity.y != KNOCKBACK_HEIGHT:
				set_state(States.IDLE)
			velocity.y += gravity*delta
		States.WALLCLING:
			velocity.y = gravity*delta*7
			_movement(delta)
			if Input.is_action_just_pressed("jump"):
				set_state(States.JUMPING)
			elif Input.is_action_just_released("left") or Input.is_action_just_released("right"):
				set_state(States.FALLING)
			elif Input.is_action_just_pressed("parry"):
				set_state(States.PARRY)
			elif not is_on_wall() or is_on_floor():
				set_state(States.IDLE)
		States.PARRY:
			parry_timer -= delta
			parry_overlay.visible = true
			if parry_timer <= 0:
				set_state(prev_state)
				parry_overlay.visible = false
	
	match current_atk_state:
		Attack_States.IDLE:
			if Input.is_action_just_pressed("attack"):
				set_attack(Attack_States.SLASH)
		Attack_States.SLASH:
			attack_timer -= delta
			if attack_timer <= 0:
				set_attack(Attack_States.IDLE)
				
	if is_invincible:
		iframe_timer -= delta
		if iframe_timer <= 0.0:
			is_invincible = false
	if canMove:
		move_and_slide()
	leg_animation.set("parameters/Run/blend_position", direction.x)
	leg_animation.set("parameters/Idle/blend_position", direction.x)
	leg_animation.set("parameters/Jump/blend_position", direction.x)
	body_animation.set("parameters/Slash/blend_position", direction)
	body_animation.set("parameters/Run/blend_position", direction.x)
	body_animation.set("parameters/Idle/blend_position", direction.x)
	if loaded == false:
		loaded = true
	
func set_state(new_state: States) -> void:
	prev_state = current_state
	current_state = new_state
	#print(States.keys()[current_state])
	match prev_state:
		States.DASH:
			if prev_velocity*direction.x <= 0:
				velocity.x = 0
			else:
				velocity.x = prev_velocity
			if new_state == States.JUMPING:
				set_state(States.FALLING)
				return
		States.WALLCLING:
			if new_state == States.JUMPING:
				velocity.x = get_wall_normal().x * 500
	match current_state:
		States.IDLE:
			velocity.x = 0
		States.RUNNING:
			pass
		States.JUMPING:
			velocity.y = JUMP_VELOCITY
		States.FALLING:
			velocity.y = 50
		States.DASH:
			prev_velocity = velocity.x
			velocity.x = direction.x * DASH_SPEED
			velocity.y = 0
			dash_time = DASH_DURATION
		States.KNOCKBACK:
			velocity.x = knock_direction*250
			velocity.y = KNOCKBACK_HEIGHT
		States.WALLCLING:
			velocity.y = 0
		States.PARRY:
			is_invincible = true
			parry_timer = PARRY_DURATION
			#velocity += KNOCKBACK_HEIGHT * direction.x
			
func set_attack(new_atk_state: Attack_States) -> void:
	current_atk_state = new_atk_state
	match current_atk_state:
		Attack_States.IDLE:
			pass
		Attack_States.SLASH:
			attack_timer = ATTACK_DURATION

func _on_sword_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		body._deal_damage(1)

func _on_sword_area_body_exited(body: Node2D) -> void:
	pass
	
func _boss_camera():
	canMove = false
	moving = 0
	animate_camera_pan(centerMarker.global_position - global_position, Vector2(0, -20), 1.0, 3.0)
	await get_tree().create_timer(6.0).timeout  
	canMove = true
	
func animate_camera_pan(target_offset: Vector2, return_offset: Vector2, hold_duration: float, pan_duration: float) -> void:
	camera_return_offset = return_offset
	camera_hold_duration = hold_duration
	camera_pan_duration = pan_duration
	var tween = create_tween()
	tween.tween_property(camera, "offset", target_offset, pan_duration) \
		 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(Callable(self, "_on_camera_hold_complete"))

func _on_camera_hold_complete() -> void:
	await get_tree().create_timer(camera_hold_duration).timeout
	var tween = create_tween()
	tween.tween_property(camera, "offset", camera_return_offset, camera_pan_duration) \
		 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _deal_damage_to_player(damage: int, enemy_position: Vector2) -> void:
	
	if global_position.x < enemy_position.x:
		knock_direction = -1
	else:
		knock_direction = 1
		
	if current_state == States.PARRY:
		print("parrying")
		_parry(damage)
		return
	if is_invincible:
		return
		
	is_invincible = true
	iframe_timer = HURT_DURATION
	var tween: Tween = create_tween().set_loops(HURT_DURATION*2)
	tween.tween_property(self, "modulate:v", 1, 0.5).from(0)
	print("dealing damage")
	health -= damage
	UI.update()
	set_state(States.KNOCKBACK)
	
	
	if health <= 0:
		_die()
	
func _die() -> void:
	get_tree().change_scene_to_file("res://Scenes/game_over.tscn")

func set_camera_limits(left, right, top, bottom) -> void:
	camera.set_limit(SIDE_LEFT, left)
	camera.set_limit(SIDE_RIGHT, right)
	camera.set_limit(SIDE_TOP, top)
	camera.set_limit(SIDE_BOTTOM, bottom)
	print(camera.limit_left, camera.limit_right, camera.limit_top, camera.limit_bottom)
