extends TileMapLayer

var highlighted_cells: Array[Vector2i] = []


func clear_moves():

	for cell in highlighted_cells:
		erase_cell(cell)

	highlighted_cells.clear()


func show_moves(cells: Array[Vector2i]):

	clear_moves()

	for cell in cells:

		# Tile ID 2
		set_cell(cell, 2, Vector2i(0, 0), 0)

		highlighted_cells.append(cell)
