extends Node

class_name MessageManager


var board: BoardState

var scroll: Scroll

var characters: Array[Character] = []


func setup(
	board_state: BoardState,
	scroll_node: Scroll,
	character_list: Array[Character]
):

	board = board_state
	scroll = scroll_node
	characters = character_list


# =====================================
# PERGAMINO
# =====================================

func check_scroll(character: Character):

	if !character.alive:
		return

	if character.current_cell != scroll.current_cell:
		return

	if character.pick_message():

		scroll.collect()

		board.add_log(
			character.name + " ahora es portador."
		)


# =====================================
# MOSTRAR
# =====================================

func can_use_show(character: Character) -> bool:

	if !character.alive:
		return false

	if !character.is_carrier():
		return false

	for cell in get_adjacent_cells(character.current_cell):

		var target: Character = board.get_occupant(cell)

		if target == null:
			continue

		if !target.alive:
			continue

		if target == character:
			continue

		if !target.is_carrier():

			return true

	return false


func use_show(character: Character) -> bool:

	if !character.alive:
		return false

	if !character.show_message():
		return false

	board.add_log(
		character.name + " utilizó Mostrar."
	)

	var transmitted := false

	for cell in get_adjacent_cells(character.current_cell):

		var target: Character = board.get_occupant(cell)

		if target == null:
			continue

		if !target.alive:
			continue

		if target == character:
			continue

		if target.pick_message():

			board.add_log(
				target.name + " recibió el mensaje."
			)

			transmitted = true

	if !transmitted:

		board.add_log(
			"Ningún personaje recibió el mensaje."
		)

	return true


# =====================================
# PROTECCIÓN
# =====================================

func use_protection(paladin: Paladin) -> bool:

	if !paladin.alive:
		return false

	board.add_log(
		paladin.name + " utilizó Protección."
	)

	var protected_someone := false

	for cell in get_adjacent_cells(paladin.current_cell):

		var target: Character = board.get_occupant(cell)

		if target == null:
			continue

		if !target.alive:
			continue

		if target == paladin:
			continue

		target.protection = true

		board.add_log(
			target.name + " recibió Protección."
		)

		protected_someone = true

	if !protected_someone:

		board.add_log(
			"No había aliados adyacentes."
		)

	return true


# =====================================
# PORTADORES
# =====================================

func get_carriers() -> Array[Character]:

	var carriers: Array[Character] = []

	for character in characters:

		if !character.alive:
			continue

		if character.is_carrier():

			carriers.append(character)

	return carriers


func has_carriers() -> bool:

	for character in characters:

		if !character.alive:
			continue

		if character.is_carrier():
			return true

	return false


# =====================================
# AUXILIARES
# =====================================

func get_adjacent_cells(cell: Vector2i) -> Array[Vector2i]:

	var cells: Array[Vector2i] = []

	var directions: Array[Vector2i] = [
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

		var target := cell + dir

		if board.is_inside_board(target):

			cells.append(target)

	return cells
