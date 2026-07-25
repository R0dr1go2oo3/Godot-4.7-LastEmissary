extends Character


func is_blocked(
	cell: Vector2i,
	ignore_units := false
) -> bool:

	if board.has_obstacle(cell):
		return true

	if !ignore_units and board.is_occupied(cell):
		return true

	return false


func get_possible_moves_from(
	cell: Vector2i,
	ignore_units := false
) -> Array[Vector2i]:

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

		var target = cell + dir

		# Fuera del tablero
		if !board.is_inside_board(target):
			continue

		# Movimiento normal
		if !is_blocked(target, ignore_units):
			moves.append(target)
			continue

		# Movimiento con salto
		var landing = target + dir

		if !board.is_inside_board(landing):
			continue

		# No puede aterrizar sobre nada
		if is_blocked(landing, ignore_units):
			continue

		moves.append(landing)

	return moves
