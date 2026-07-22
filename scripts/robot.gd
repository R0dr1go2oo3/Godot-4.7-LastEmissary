extends Character


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

		# No puede caer sobre obstáculos
		if board.has_obstacle(target):
			continue

		# No puede caer sobre otra pieza
		if board.is_occupied(target):
			continue

		moves.append(target)

	return moves
