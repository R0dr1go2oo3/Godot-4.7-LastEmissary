extends TileMapLayer

@export var base_layer: TileMapLayer

var last_cell := Vector2i(99999, 99999)

func _process(_delta):

	if base_layer == null:
		return

	var mouse_local := base_layer.to_local(get_global_mouse_position())
	var cell := base_layer.local_to_map(mouse_local)

	if cell == last_cell:
		return

	if last_cell != Vector2i(99999, 99999):
		erase_cell(last_cell)

	# Tile ID 1
	set_cell(cell, 1, Vector2i(0, 0), 0)

	last_cell = cell
