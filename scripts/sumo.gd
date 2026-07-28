extends Character


func is_blocked(
	cell: Vector2i,
	ignore_units := false
) -> bool:

	if board.has_obstacle(cell):
		return true

	if !ignore_units and board.is_occupied(cell):
		return true

	if !ignore_units and board.has_enemy(cell):
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

		# No puede aterrizar sobre obstáculos
		if board.has_obstacle(landing):
			continue

		# No puede aterrizar sobre otro personaje
		if !ignore_units and board.is_occupied(landing):
			continue

		# Puede aterrizar sobre un enemigo

		moves.append(landing)

	return moves


func move_to(cell: Vector2i) -> bool:

	var direction := cell - current_cell

	if abs(direction.x) == 2 or abs(direction.y) == 2:

		var jumped_cell := current_cell + Vector2i(
			sign(direction.x),
			sign(direction.y)
		)

		var enemy: Enemy = board.get_enemy(jumped_cell)

		if enemy != null:

			enemy.take_damage(enemy.health)

	return super.move_to(cell)
