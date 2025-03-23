extends CanvasLayer

@export var player: Player
@onready var health = $"Health Bar"
@onready var energy = $"Energy Bar"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health.max_value = player.MAX_HEALTH
	health.value = player.health
	
	energy.max_value = player.MAX_ENERGY
	energy.value = player.energy

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update() -> void:
	health.value = player.health
	energy.value = player.energy
