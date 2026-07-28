extends Enemy

class_name GuerreroDiagonal


func get_possible_moves_from(
	cell: Vector2i
) -> Array[Vector2i]:

	var moves: Array[Vector2i] = []

	var directions: Array[Vector2i] = [
		Vector2i(-1, -1),
		Vector2i(1, -1),
		Vector2i(-1, 1),
		Vector2i(1, 1)
	]

	for dir in directions:

		var target := cell + dir

		if can_move(target):

			moves.append(target)

	return moves


func get_attack_cells_from(
	cell: Vector2i
) -> Array[Vector2i]:

	var cells: Array[Vector2i] = []

	var directions: Array[Vector2i] = [
		Vector2i(-1, -1),
		Vector2i(1, -1),
		Vector2i(-1, 1),
		Vector2i(1, 1)
	]

	for dir in directions:

		var target := cell + dir

		if board.is_inside_board(target):

			cells.append(target)

	return cells


func attack():

	if !alive:
		return

	for cell in get_attack_cells():

		var character: Character = board.get_occupant(cell)

		if character == null:
			continue

		print(name, " atacó a ", character.name)

		character.take_damage(1)

		return


func move_random():

	var moves := get_possible_moves()

	if moves.is_empty():
		return

	moves.shuffle()

	move_to(moves[0])


func take_turn():

	if !alive:
		return

	# Si puede atacar desde el inicio,
	# consume las dos acciones atacando.
	if has_target():

		attack()

		return

	# Primera acción: moverse.
	move_random()

	# Segunda acción: comprobar nuevamente.
	if has_target():

		attack()
