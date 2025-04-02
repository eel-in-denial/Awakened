extends Area2D

const EXPLOSION_RADIUS = 50.0 
const EXPLOSION_DAMAGE = 10  
const EXPLOSION_DURATION = 0.3
const SPEED = 300

@onready var explosion_sprite: Sprite2D = $ExplosionSprite 
@onready var explosion_shape: CollisionShape2D = $ExplosionShape
@onready var damage_area: Area2D = $DamageArea 
var boss: CharacterBody2D
var direction: Vector2
var is_exploding = false  
var velocity
@onready var player = Global.player

func _ready() -> void:
	velocity = direction * 200

func _process(delta: float) -> void:
	if self.overlaps_body(player):
		player._deal_damage_to_player(1, self)
		
	if global_position.y > boss.global_position.y + 230:
		is_exploding = true
		
	if !is_exploding:
		global_position += velocity * delta
	else:
		_explosion()

func _explosion() -> void:
	explosion_shape.disabled = false
	explosion_sprite.visible = true
	await get_tree().create_timer(0.3).timeout
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body == player:
		is_exploding = true
		_explosion()
