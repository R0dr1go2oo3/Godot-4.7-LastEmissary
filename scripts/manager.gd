extends Node

var turn := 1

var robot: Node = null

var robot_moves := 0
var pieces_moved := []

var selected_character = null

var board

var mouse_tile
var moves_tile

var characters := []

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
	character_list: Array
):

	board = board_state

	mouse_tile = mouse_layer
	moves_tile = moves_layer

	board.setup(
		ground_tile,
		obstacle_tile
	)

	characters = character_list
	robot = characters[3]

	start_game()


func start_game():

	randomize()

	board.create_board()
	board.create_obstacles()

	mouse_tile.ground_tile = board.ground_tile

	spawn_cells.shuffle()

	for i in characters.size():

		characters[i].spawn(
			spawn_cells[i],
			board
		)

		board.set_occupant(
			characters[i].current_cell,
			characters[i]
		)

	print("Turno:", turn)


func handle_click(cell: Vector2i):

	var piece = board.get_occupant(cell)

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


func select_piece(piece):

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


func move_selected(cell):

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

	register_move(selected_character)

	deselect()

	check_end_turn()


func can_select(piece) -> bool:

	if piece == robot:

		if turn % 2 != 0:
			print("El Robot está recargando")
			return false

		if robot_moves >= 3:
			return false

	elif piece in pieces_moved:

		return false

	return true


func register_move(piece):

	if piece == robot:
		robot_moves += 1
	else:
		pieces_moved.append(piece)


func get_required_actions():

	if turn % 2 != 0:
		return 3

	return 6


func get_current_actions():

	return pieces_moved.size() + robot_moves


func check_end_turn():

	if get_current_actions() != get_required_actions():
		return

	turn += 1

	pieces_moved.clear()
	robot_moves = 0

	print("Turno:", turn)
