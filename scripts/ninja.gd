extends Node2D

var board: TileMapLayer
var current_cell: Vector2i

var selected := false


func spawn(cell: Vector2i, board_layer: TileMapLayer):

	board = board_layer
	current_cell = cell

	position = board.map_to_local(cell)


func get_possible_moves() -> Array[Vector2i]:

	var moves: Array[Vector2i] = []

	var directions = [
		Vector2i(2, 2),
		Vector2i(2, -2),
		Vector2i(-2, 2),
		Vector2i(-2, -2)
	]

	for dir in directions:

		var target = current_cell + dir

		# Fuera del tablero
		if !board.is_inside_board(target):
			continue

		# No puede caer sobre obstáculos
		if board.has_obstacle(target):
			continue

		# No puede caer sobre otra pieza
		if board.is_occupied(target):
			continue

		moves.append(target)

	return moves


func move_to(cell: Vector2i) -> bool:

	# Fuera del tablero
	if !board.is_inside_board(cell):
		return false

	# Obstáculos bloquean el destino
	if board.has_obstacle(cell):
		print("No puedes moverte sobre un obstáculo")
		return false

	# Otra pieza ocupa la casilla
	if board.is_occupied(cell):
		print("Casilla ocupada")
		return false

	# Verifica movimiento válido
	if cell not in get_possible_moves():
		print("Movimiento inválido")
		return false

	current_cell = cell
	position = board.map_to_local(cell)

	print("Ninja movido a ", cell)

	return true
