extends Node2D

var board: TileMapLayer
var current_cell: Vector2i

var selected := false


func spawn(cell: Vector2i, board_layer: TileMapLayer):

	board = board_layer
	current_cell = cell

	position = board.map_to_local(cell)


func is_blocked(cell: Vector2i) -> bool:

	return (
		board.is_occupied(cell)
		or board.has_obstacle(cell)
	)


func get_possible_moves() -> Array[Vector2i]:

	var moves: Array[Vector2i] = []

	var directions = [
		Vector2i(-1, -1),
		Vector2i(0, -1),
		Vector2i(1, -1),
		Vector2i(-1, 0),
		Vector2i(1, 0),
		Vector2i(-1, 1),
		Vector2i(0, 1),
		Vector2i(1, 1)
	]

	for dir in directions:

		var target = current_cell + dir

		# Fuera del tablero
		if !board.is_inside_board(target):
			continue


		# Movimiento normal
		if !is_blocked(target):
			moves.append(target)
			continue


		# Movimiento con salto
		var landing = target + dir

		if !board.is_inside_board(landing):
			continue

		# No puede aterrizar sobre nada
		if is_blocked(landing):
			continue

		moves.append(landing)


	return moves


func move_to(cell: Vector2i) -> bool:

	if !board.is_inside_board(cell):
		return false


	if cell not in get_possible_moves():
		print("Movimiento inválido")
		return false


	current_cell = cell
	position = board.map_to_local(cell)

	print("Sumo movido a ", cell)

	return true
