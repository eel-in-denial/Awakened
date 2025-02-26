#@tool
extends TileMapLayer
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#
#func _process(delta: float) -> void:
	#if Engine.is_editor_hint():
		#InputMap.load_from_project_settings()
		#if Input.is_action_just_pressed("click"):
			#var clicked_cell = local_to_map(get_local_mouse_position())
			#var neighbour_array = get_clicked_tile_neighbours(clicked_cell)
			#if neighbour_array[0] == 1 and neighbour_array[1] == 1 and neighbour_array[2] == 1:
				#set_cell(clicked_cell, 1, Vector2i(randi_range(3, 5), 0))
			#elif neighbour_array[0] == 2 and neighbour_array[1] == 2 and neighbour_array[2] == 2:
				#set_cell(clicked_cell, 1, Vector2i(randi_range(6, 7), 0))
			##var tile_position = local_to_map(mouse_position)
			##for cell in get_clicked_tile_neighbours():
				##pass
			#print()
			#
#func get_clicked_tile_neighbours(clicked_cell):
	#var data = get_cell_tile_data(clicked_cell)
	#var tile_neighbours = []
	#if data:
		#for y in range(-1, 2):
			#for x in range(-1, 2):
				#var vector = Vector2i(clicked_cell.x+x, clicked_cell.y+y)
				#var tile = get_cell_tile_data(vector)
				#if tile:
					#tile_neighbours.append(tile.get_custom_data("depth"))
				#else:
					#tile_neighbours.append(null)
		#return tile_neighbours
	#else:
		#return 0
