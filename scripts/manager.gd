extends Node

var board: BoardState

var robot: Character = null
var characters: Array[Character] = []

var selected_character: Character = null

var mouse_tile: TileMapLayer
var moves_tile: TileMapLayer

var scroll: Scroll


@onready var turn_manager: TurnManager = $turnManager
@onready var message_manager: MessageManager = $messageManager
@onready var game_setup: GameSetup = $gameSetup


func setup(
	board_state: BoardState,
	ground_tile: TileMapLayer,
	obstacle_tile: TileMapLayer,
	mouse_layer: TileMapLayer,
	moves_layer: TileMapLayer,
	character_list: Array[Character],
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

	turn_manager.setup(robot)

	message_manager.setup(
		board,
		scroll,
		characters
	)

	game_setup.setup(
		board,
		mouse_tile,
		scroll,
		characters
	)

	game_setup.start_game()


func find_robot() -> Character:

	for character in characters:

		if character.name == "Robot":
			return character

	push_error("No se encontró un Robot.")

	return null


func handle_click(cell: Vector2i):

	var piece: Character = board.get_occupant(cell)

	if selected_character == null:

		if piece == null:
			return

		if !turn_manager.can_act(piece):
			return

		select_piece(piece)
		return

	if piece == selected_character:

		deselect()
		return

	if piece != null:

		if !turn_manager.can_act(piece):
			return

		select_piece(piece)
		return

	move_selected(cell)


func handle_right_click():

	if selected_character == null:
		return

	if !turn_manager.can_act(selected_character):
		return

	if !message_manager.use_show(selected_character):
		return

	turn_manager.register_action(selected_character)

	deselect()

	if turn_manager.should_end_turn():
		turn_manager.end_turn()


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

	var old_cell := selected_character.current_cell

	if !selected_character.move_to(cell):
		return

	board.move_occupant(
		old_cell,
		selected_character.current_cell
	)

	message_manager.check_scroll(selected_character)

	turn_manager.register_action(selected_character)

	deselect()

	if turn_manager.should_end_turn():
		turn_manager.end_turn()
