extends Sprite2D
@onready var anim = $AnimationPlayer

func _ready() -> void:
	anim.play("new_animation")
