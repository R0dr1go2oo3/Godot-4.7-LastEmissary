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


func use_collect(character: Character) -> bool:

	if !character.alive:
		return false

	if character.is_carrier():

		board.add_log(
			character.name + " ya es portador."
		)

		return false

	for cell in get_adjacent_cells(character.current_cell):

		if !board.has_scroll(cell):
			continue

		if character.pick_message():

			scroll.collect()

			board.add_log(
				character.name + " recogió el pergamino."
			)

			return true

	board.add_log(
		"No hay ningún pergamino cercano."
	)

	return false


# =====================================
# MOSTRAR
# =====================================

func can_use_show(character: Character) -> bool:

	if !character.alive:
		return false

	# Si todavía no es portador,
	# solo puede usar la habilidad si
	# hay un pergamino adyacente.
	if !character.is_carrier():

		for cell in get_adjacent_cells(character.current_cell):

			if board.has_scroll(cell):

				return true

		return false

	# Ya es portador: comprobar si hay
	# alguien a quien transmitir el mensaje.
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

	# Antes de ser portador,
	# el botón funciona como Recoger.
	if !character.is_carrier():

		return use_collect(character)

	if !character.show_message():
		return false

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

			transmitted = true

			board.add_log(
				target.name + " recibió el mensaje."
			)

	if !transmitted:

		board.add_log(
			"Ningún personaje recibió el mensaje."
		)

		return false

	board.add_log(
		character.name + " utilizó Mostrar."
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
