extends Node2D

var board: TileMapLayer
var current_cell: Vector2i

var selected := false


func spawn(cell: Vector2i, board_layer: TileMapLayer):

	board = board_layer
	current_cell = cell

	position = board.map_to_local(cell)


func move_to(cell: Vector2i) -> bool:

	var dx = cell.x - current_cell.x
	var dy = cell.y - current_cell.y

	# Solo puede intentar moverse una casilla en cualquiera de las 8 direcciones
	if abs(dx) > 1 or abs(dy) > 1 or (dx == 0 and dy == 0):
		print("Movimiento inválido")
		return false

	# Si la casilla está ocupada, intentar saltarla
	if board.is_occupied(cell):

		var landing := cell + Vector2i(dx, dy)

		if !board.is_inside_board(landing):
			print("No puede saltar fuera del tablero")
			return false

		if board.is_occupied(landing):
			print("No puede aterrizar sobre otra pieza")
			return false

		cell = landing

	# Ya sea movimiento normal o salto, comprobar tablero
	if !board.is_inside_board(cell):
		return false

	current_cell = cell
	position = board.map_to_local(cell)

	print("Sumo movido a ", cell)

	return true
