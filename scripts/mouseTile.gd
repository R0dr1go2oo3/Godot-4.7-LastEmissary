extends TileMapLayer

@export var ground_tile: TileMapLayer

var last_cell := Vector2i(99999, 99999)


func _process(_delta):

	if ground_tile == null:
		return

	var mouse_local := ground_tile.to_local(get_global_mouse_position())
	var cell := ground_tile.local_to_map(mouse_local)

	if cell == last_cell:
		return

	if last_cell != Vector2i(99999, 99999):
		erase_cell(last_cell)

	# Tile ID 1
	set_cell(cell, 1, Vector2i(0, 0), 0)

	last_cell = cell
