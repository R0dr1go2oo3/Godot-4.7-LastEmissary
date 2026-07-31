extends Character


func get_possible_moves_from(
	cell: Vector2i,
	ignore_units := false
) -> Array[Vector2i]:

	var moves: Array[Vector2i] = []

	var directions: Array[Vector2i] = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1)
	]

	for dir: Vector2i in directions:

		var middle: Vector2i = cell + dir

		if !board.is_inside_board(middle):
			continue

		# No puede atravesar obstáculos.
		if board.has_obstacle(middle):
			continue

		# No puede atravesar personajes.
		if !ignore_units and board.is_occupied(middle):
			continue

		# =====================================
		# ENEMIGO A 1 CASILLA
		# Solo puede atacarlo.
		# =====================================

		if board.has_enemy(middle):

			moves.append(middle)
			continue

		# =====================================
		# PERGAMINO A 1 CASILLA
		# Puede recogerlo o saltarlo.
		# =====================================

		if board.has_scroll(middle):

			moves.append(middle)

		var target: Vector2i = cell + dir * 2

		# Permitir un salto reducido hacia la meta.
		if dir.x == 1 and target.x == BoardState.ROWS:

			target = Vector2i(BoardState.ROWS - 1, target.y)

		if !board.is_inside_board(target):
			continue

		# No puede caer sobre obstáculos.
		if board.has_obstacle(target):
			continue

		# No puede caer sobre otro personaje.
		if !ignore_units and board.is_occupied(target):
			continue

		# No puede caer sobre casillas destruidas.
		if board.is_destroyed(target):
			continue

		moves.append(target)

	return moves
