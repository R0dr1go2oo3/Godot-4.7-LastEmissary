extends Node2D

var board: TileMapLayer
var current_cell: Vector2i

var selected := false


func spawn(cell: Vector2i, board_layer: TileMapLayer):

	board = board_layer
	current_cell = cell

	position = board.map_to_local(cell)


func move_to(cell: Vector2i) -> bool:

	# No salir del tablero
	if cell.x < 0 or cell.x >= board.ROWS:
		return false

	if cell.y < 0 or cell.y >= board.COLUMNS:
		return false

	var dx = cell.x - current_cell.x
	var dy = cell.y - current_cell.y

	var movimiento_valido = (
		(abs(dx) == 2 and dy == 0) or
		(abs(dy) == 2 and dx == 0)
	)

	if !movimiento_valido:
		print("Movimiento inválido")
		return false

	current_cell = cell
	position = board.map_to_local(cell)

	print("Robot movido a ", cell)

	return true
