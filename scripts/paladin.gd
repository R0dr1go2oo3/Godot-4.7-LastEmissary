extends Node2D

var board: TileMapLayer
var current_cell: Vector2i

var selected := false


func spawn(cell: Vector2i, board_layer: TileMapLayer):

	board = board_layer
	current_cell = cell

	position = board.map_to_local(cell)


func move_to(cell: Vector2i):

	# No salir del tablero
	if cell.x < 0 or cell.x >= board.ROWS:
		return

	if cell.y < 0 or cell.y >= board.COLUMNS:
		return

	current_cell = cell
	position = board.map_to_local(cell)

	print("Paladín movido a ", cell)
