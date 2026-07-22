extends Character


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
		var middle = current_cell + dir / 2

		# Fuera del tablero
		if !board.is_inside_board(target):
			continue

		# No puede saltar sobre piezas u obstáculos
		if board.is_occupied(middle) or board.has_obstacle(middle):
			continue

		# No puede caer sobre obstáculos
		if board.has_obstacle(target):
			continue

		# No puede caer sobre otra pieza
		if board.is_occupied(target):
			continue

		moves.append(target)

	return moves
