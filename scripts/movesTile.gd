extends TileMapLayer

var visible_moves: Array[Vector2i] = []


func clear_moves():

	for cell in visible_moves:
		erase_cell(cell)

	visible_moves.clear()


func show_moves(cells: Array[Vector2i]):

	clear_moves()

	for cell in cells:

		# Tile ID 2
		set_cell(cell, 2, Vector2i(0, 0), 0)

		visible_moves.append(cell)
