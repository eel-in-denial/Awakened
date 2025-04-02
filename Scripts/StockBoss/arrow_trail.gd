extends Line2D

var length = 500
var point : Vector2
var player = Global.player
@onready var hitbox = $Area2D

func _ready() -> void:
	global_position = Vector2(0, 0)
	print("spawning line at")
	print(global_position)
	pass

func add_new_point(new_point: Vector2):
	add_point(new_point) 

	var point_count = get_point_count()
	if point_count > 1:
		var new_shape = CollisionShape2D.new()
		var segment = SegmentShape2D.new()
		
		segment.a = get_point_position(point_count - 2)
		segment.b = get_point_position(point_count - 1)
		new_shape.shape = segment
		
		$Area2D.add_child(new_shape)

func _process(delta):
	if hitbox.overlaps_body(player):
		player._deal_damage_to_player(1, self)
	var new_point = get_parent().global_position
	add_new_point(new_point)


func fade_out():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
