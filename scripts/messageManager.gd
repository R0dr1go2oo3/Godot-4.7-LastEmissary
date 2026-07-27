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

	if character.current_cell != scroll.current_cell:
		return

	if character.pick_message():

		scroll.collect()

		print(character.name, " ahora es portador.")


# =====================================
# MOSTRAR
# =====================================

func use_show(character: Character) -> bool:

	if !character.show_message():
		return false

	print(character.name, " utilizó Mostrar.")

	var transmitted := false

	for cell in get_adjacent_cells(character.current_cell):

		var target: Character = board.get_occupant(cell)

		if target == null:
			continue

		if target == character:
			continue

		if target.pick_message():

			print(target.name, " recibió el mensaje.")

			transmitted = true

	if !transmitted:

		print("Ningún personaje recibió el mensaje.")

	return true


# =====================================
# PORTADORES
# =====================================

func get_carriers() -> Array[Character]:

	var carriers: Array[Character] = []

	for character in characters:

		if character.is_carrier():

			carriers.append(character)

	return carriers


func has_carriers() -> bool:

	for character in characters:

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
