extends CharacterBody2D

@export var gravity: float = 800
@export var attack_cooldown: float = 2.0
@export var crash_speed: float = 600
@export var return_speed: float = 400
@export var projectile_scene: PackedScene
@export var frag_projectile_scene: PackedScene
@export var stock_arrow_scene: PackedScene

var start_position: Vector2
var attacking: bool = false
var attack_timer: float = 0

func _ready():
	start_position = position

func _process(delta):
	attack_timer -= delta
	if attack_timer <= 0:
		_choose_attack()
		attack_timer = attack_cooldown

func _choose_attack():
	var attack_choice = randi() % 3
	match attack_choice:
		0:
			_market_crash()
		1:
			_stock_arrows()
		2:
			_bubble_burst()

func _market_crash():
	attacking = true
	await _play_crash_animation()
	var target_position = start_position + Vector2(0, 300)  # Adjust drop distance
	while position.y < target_position.y:
		position.y += crash_speed * get_process_delta_time()
		await get_tree().process_frame
	_create_shockwaves()
	await get_tree().create_timer(0.5).timeout  # Delay before returning
	while position.y > start_position.y:
		position.y -= return_speed * get_process_delta_time()
		await get_tree().process_frame
	attacking = false

func _create_shockwaves():
	# Create shockwave effects (implement as needed)
	pass

func _stock_arrows():
	attacking = true
	for i in range(5):  # Adjust for more or fewer arrows
		var arrow = stock_arrow_scene.instantiate()
		arrow.position = Vector2(start_position.x + (i % 2) * 600 - 300, start_position.y)
		get_parent().add_child(arrow)
		await get_tree().create_timer(0.3).timeout
	attacking = false

func _bubble_burst():
	attacking = true
	for i in range(5):
		var bubble = projectile_scene.instantiate()
		bubble.position = Vector2(randf_range(100, 700), randf_range(100, 400))
		bubble.set_explode_callback(_spawn_frags)
		get_parent().add_child(bubble)
		await get_tree().create_timer(0.4).timeout
	attacking = false

func _spawn_frags(position):
	for i in range(3):
		var frag = frag_projectile_scene.instantiate()
		frag.position = position
		get_parent().add_child(frag)
