extends Character


func get_possible_moves_from(
	cell: Vector2i,
	ignore_units := false
) -> Array[Vector2i]:

	var moves: Array[Vector2i] = []

	var directions = [
		Vector2i(2, 2),
		Vector2i(2, -2),
		Vector2i(-2, 2),
		Vector2i(-2, -2)
	]

	for dir in directions:

		var target = cell + dir
		var middle = cell + dir / 2

		# Fuera del tablero
		if !board.is_inside_board(target):
			continue

		# No puede saltar sobre obstáculos
		if board.has_obstacle(middle):
			continue

		# No puede saltar sobre otra pieza
		if !ignore_units and board.is_occupied(middle):
			continue

		# No puede caer sobre obstáculos
		if board.has_obstacle(target):
			continue

		# No puede caer sobre otra pieza
		if !ignore_units and board.is_occupied(target):
			continue

		moves.append(target)

	return moves
