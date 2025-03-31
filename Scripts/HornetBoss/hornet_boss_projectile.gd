extends CharacterBody2D

@export var speed: float = 300.0
var direction: Vector2 = Vector2.ZERO

# Optional: Limit the number of bounces before the projectile disappears.
var bounce_count: int = 0
const MAX_BOUNCES: int = 5

func _ready() -> void:
	if owner:
		add_collision_exception_with(owner)

func _physics_process(delta: float) -> void:
	# Move the projectile and check for collisions.
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		var collided_object = collision.get_collider()
		# If we hit the Player, deal damage and remove the projectile.
		if collided_object is Player:
			collided_object._deal_damage_to_player(1, self)
			queue_free()
		else:
			# Bounce off other surfaces by reflecting the direction using the collision normal.
			direction = direction.bounce(collision.get_normal())
			bounce_count += 1
			if bounce_count > MAX_BOUNCES:
				queue_free()
