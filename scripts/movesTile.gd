extends TileMapLayer

var visible_moves: Array[Vector2i] = []


func clear_moves():

	for cell in visible_moves:
		erase_cell(cell)

	visible_moves.clear()


func show_moves(
	selected_cell: Vector2i,
	cells: Array[Vector2i]
):

	clear_moves()

	# Resaltar la casilla del personaje.
	set_cell(
		selected_cell,
		2,
		Vector2i(0, 0),
		0
	)

	visible_moves.append(selected_cell)

	# Resaltar los movimientos.
	for cell in cells:

		if cell == selected_cell:
			continue

		set_cell(
			cell,
			2,
			Vector2i(0, 0),
			0
		)

		visible_moves.append(cell)
