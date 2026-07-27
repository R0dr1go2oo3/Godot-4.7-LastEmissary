extends Node

var turn := 1

var board: BoardState

var robot: Character = null
var characters = []

var selected_character: Character = null

var robot_actions := 0
var pieces_acted := []

var mouse_tile
var moves_tile

var scroll: Scroll

var spawn_cells := [
	Vector2i(0, 0),
	Vector2i(0, 3),
	Vector2i(0, 6),
	Vector2i(0, 9)
]


func setup(
	board_state,
	ground_tile,
	obstacle_tile,
	mouse_layer,
	moves_layer,
	character_list: Array,
	scroll_node: Scroll
):

	board = board_state

	mouse_tile = mouse_layer
	moves_tile = moves_layer

	board.setup(
		ground_tile,
		obstacle_tile
	)

	characters = character_list
	robot = find_robot()

	scroll = scroll_node

	start_game()


func find_robot() -> Character:

	for character in characters:

		if character.name == "Robot":
			return character

	push_error("No se encontró un Robot.")

	return null


func start_game():

	randomize()

	board.create_board()

	for character in characters:
		character.setup_board(board)

	while true:

		board.create_obstacles()

		spawn_cells.shuffle()

		var valid := true

		board.clear_occupants()

		for i in range(characters.size()):

			characters[i].current_cell = spawn_cells[i]

			board.set_occupant(
				characters[i].current_cell,
				characters[i]
			)

		for character in characters:

			if !board.can_reach_goal(character):

				valid = false
				break

		if valid:
			break

	mouse_tile.ground_tile = board.ground_tile

	for i in range(characters.size()):

		characters[i].spawn(spawn_cells[i])

		board.set_occupant(
			characters[i].current_cell,
			characters[i]
		)

	scroll.setup(board)
	scroll.spawn(board.get_random_scroll_cell())

	print("Turno:", turn)


func handle_click(cell: Vector2i):

	var piece: Character = board.get_occupant(cell)

	if selected_character == null:

		if piece == null:
			return

		if !can_select(piece):
			return

		select_piece(piece)
		return

	if piece == selected_character:

		deselect()
		return

	if piece != null:

		if !can_select(piece):
			return

		select_piece(piece)
		return

	move_selected(cell)


func handle_right_click():

	if selected_character == null:
		return

	if !can_act(selected_character):
		return

	if !use_show(selected_character):
		return

	register_action(selected_character)

	deselect()

	check_end_turn()


func select_piece(piece: Character):

	if selected_character != null:
		selected_character.selected = false

	selected_character = piece
	selected_character.selected = true

	moves_tile.show_moves(piece.get_possible_moves())

	print(piece.name, " seleccionado")


func deselect():

	if selected_character == null:
		return

	selected_character.selected = false
	selected_character = null

	moves_tile.clear_moves()


func move_selected(cell: Vector2i):

	if !(cell in selected_character.get_possible_moves()):

		deselect()
		return

	var old_cell: Vector2i = selected_character.current_cell

	if !selected_character.move_to(cell):
		return

	board.move_occupant(
		old_cell,
		selected_character.current_cell
	)

	if selected_character.current_cell == scroll.current_cell:

		if selected_character.pick_message():

			scroll.collect()

			print(selected_character.name, " ahora es portador.")

	register_action(selected_character)

	deselect()

	check_end_turn()


func use_show(character: Character) -> bool:

	if !character.show_message():
		return false

	print(character.name, " utilizó Mostrar.")

	var transmitted := false

	for cell: Vector2i in get_adjacent_cells(character.current_cell):

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

	for dir: Vector2i in directions:

		var target: Vector2i = cell + dir

		if board.is_inside_board(target):

			cells.append(target)

	return cells


func can_select(piece: Character) -> bool:

	return can_act(piece)


func can_act(piece: Character) -> bool:

	if piece == robot:

		if turn % 2 != 0:

			print("El Robot está recargando")
			return false

		if robot_actions >= 3:
			return false

	elif piece in pieces_acted:

		return false

	return true


func register_action(piece: Character):

	if piece == robot:
		robot_actions += 1
	else:
		pieces_acted.append(piece)


func get_carriers() -> Array[Character]:

	var carriers: Array[Character] = []

	for character: Character in characters:

		if character.is_carrier():
			carriers.append(character)

	return carriers


func has_carriers() -> bool:

	for character: Character in characters:

		if character.is_carrier():
			return true

	return false


func get_required_actions() -> int:

	if turn % 2 != 0:
		return 3

	return 6


func get_current_actions() -> int:

	return pieces_acted.size() + robot_actions


func check_end_turn():

	if get_current_actions() != get_required_actions():
		return

	turn += 1

	pieces_acted.clear()
	robot_actions = 0

	print("Turno:", turn)
