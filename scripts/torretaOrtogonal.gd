extends Enemy

class_name TorretaOrtogonal


func get_possible_moves_from(
	_cell: Vector2i
) -> Array[Vector2i]:

	# Las torretas no se mueven.
	return []


func get_attack_cells_from(
	cell: Vector2i
) -> Array[Vector2i]:

	var cells: Array[Vector2i] = []

	var directions: Array[Vector2i] = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1)
	]

	for dir in directions:

		var target := cell + dir

		if !board.is_inside_board(target):
			continue

		cells.append(target)

	return cells


func attack():

	if !alive:
		return

	for cell in get_attack_cells():

		var character: Character = board.get_occupant(cell)

		if !is_valid_target(character):
			continue

		board.add_log(
			name + " atacó a " + character.name + "."
		)

		character.take_damage(1)


func take_turn():

	if !alive:
		return

	if has_target():

		attack()
