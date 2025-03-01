#@tool
extends TileMapLayer
#var clicked_cell
### Called when the node enters the scene tree for the first time.
##func _ready() -> void:
	##pass
##
##
### Called every frame. 'delta' is the elapsed time since the previous frame.
#
#func _process(delta: float) -> void:
	#if Engine.is_editor_hint():
		#InputMap.load_from_project_settings()
		#if Input.is_action_pressed("click") and clicked_cell != local_to_map(get_local_mouse_position()):
			#clicked_cell = local_to_map(get_local_mouse_position())
			#if get_cell_tile_data(clicked_cell):
				#autotile(clicked_cell)
			#
#func autotile(tile_clicked):
	#for vector in get_surrounding_vectors(tile_clicked):
		#if get_cell_tile_data(vector):
			#var tile_depths = []
			#for tile in get_surrounding_tiles(vector):
				#if tile:
					#tile_depths.append(tile.get_custom_data("depth"))
				#else:
					#tile_depths.append(0)
			#print(tile_depths)
			#check_and_assign(vector, tile_depths)
#
#func get_surrounding_vectors(vector):
	#var vectors = []
	#for y in range(-1, 2):
			#for x in range(-1, 2):
				#vectors.append(Vector2i(vector.x+x, vector.y+y))
	#return vectors
#
#func get_surrounding_tiles(vector):
	#var tiles = []
	#for y in range(-1, 2):
			#for x in range(-1, 2):
				#var tile = get_cell_tile_data(Vector2i(vector.x+x, vector.y+y))
				#tiles.append(tile)
	#return tiles
	#
#func check_and_assign(position, array):
	#if array.slice(0, 3) == [2, 2, 1] and array[5] == 1:
		#set_cell(position, 1, Vector2i(5, 6))
	#elif array.slice(0, 4) == [1, 2, 2, 1]:
		#set_cell(position, 1, Vector2i(1, 6))
	#elif array.slice(0, 3) == [3, 3, 3] and array[3] == 1:
		#set_cell(position, 1, Vector2i(5, 9))
	#elif array.slice(0, 4) == [3, 3, 3, 3]:
		#set_cell(position, 1, Vector2i(1, 9))
	#elif array.slice(0, 3) == [0, 0, 0]:
		#set_cell(position, 1, Vector2i(randi_range(2, 4), 2))
	#elif array.slice(0, 3) == [1, 1, 1]:
		#set_cell(position, 1, Vector2i(randi_range(2, 4), 5))
	#elif array.slice(0, 3) == [2, 2, 2]:
		#set_cell(position, 1, Vector2i(randi_range(2, 4), 6))
	#elif array.slice(0, 3) == [3, 3, 3]:
		#set_cell(position, 1, Vector2i(randi_range(2, 4), 9))
	#elif array.slice(0, 3) == [4, 4, 4] or array.slice(0, 3) == [5, 5, 5]:
		#set_cell(position, 1, Vector2i(6, 11))
	##elif neighbour_array[0] == 2 and neighbour_array[1] == 2 and neighbour_array[2] == 2:
		##set_cell(clicked_cell, 1, Vector2i(randi_range(6, 7), 0))
		##pass
	#
	#
	#
