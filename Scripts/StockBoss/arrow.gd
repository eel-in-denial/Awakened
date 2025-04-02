extends Area2D

@export var speed = 200.0
var direction = Vector2.ZERO
var player = Global.player
@onready var timer = $Timer
@onready var death = $DeathTimer
@onready var sprite = $Sprite2D
var boss : CharacterBody2D
var can_turn = true 
@onready var trail = $ArrowTrail

func _ready() -> void:
	timer.wait_time = randf_range(0.3, 0.5) 
	timer.start()
	death.wait_time = 5
	death.start()

func _physics_process(delta):
	if self.overlaps_body(player):
		player._deal_damage_to_player(1, self)
	
	if can_turn and (position.y < (boss.global_position.y + 50) or position.y > boss.global_position.y + 200):
		direction.y *= -1
		can_turn = false
		await get_tree().create_timer(0.3).timeout

	_update_sprite_direction()

	position += direction * speed * delta
	
func _switch_arrow_direction():
	direction.y *= -1 
	trail.default_color = "e61400" if direction.y > 0 else "009d00"
	timer.wait_time = randf_range(0.3, 1) 
	timer.start()

func _update_sprite_direction():
	if direction.y > 0:
		self.rotation_degrees = 45 * 2.5 if direction.x > 0 else -45 * 2.5
	else:
		self.rotation_degrees = 45 * 1.5 if direction.x > 0 else -45 * 1.5


func _on_death_timer_timeout() -> void:
	trail.fade_out()
	await get_tree().create_timer(1.0).timeout
	queue_free()
	
