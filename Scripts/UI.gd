extends CanvasLayer

@onready var heart = $HBoxContainer/Heart
@export var player: Player
var hearts_list : Array[TextureRect]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var hearts_parent = $"Health Bar"
	for child in hearts_parent.get_children():
		hearts_list.append(child)
	for h in player.health:
		hearts_list[h].visible = true
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func remove_heart(num) -> void:
	hearts_list[player.health-1].visible = false
