extends Node

class_name GameSetup


var board: BoardState

var mouse_tile: TileMapLayer

var scroll: Scroll

var characters: Array[Character] = []

var spawn_cells: Array[Vector2i] = [
	Vector2i(0, 0),
	Vector2i(0, 3),
	Vector2i(0, 6),
	Vector2i(0, 9)
]


func setup(
	board_state: BoardState,
	mouse_layer: TileMapLayer,
	scroll_node: Scroll,
	character_list: Array[Character]
):

	board = board_state
	mouse_tile = mouse_layer
	scroll = scroll_node
	characters = character_list


func start_game():

	randomize()

	board.create_board()

	setup_characters()

	generate_valid_board()

	mouse_tile.ground_tile = board.ground_tile

	spawn_characters()

	spawn_scroll()


func setup_characters():

	for character in characters:

		character.setup_board(board)


func generate_valid_board():

	while true:

		board.create_obstacles()

		spawn_cells.shuffle()

		board.clear_occupants()

		assign_spawn_cells()

		if board_is_valid():
			break


func assign_spawn_cells():

	for i in range(characters.size()):

		characters[i].current_cell = spawn_cells[i]

		board.set_occupant(
			spawn_cells[i],
			characters[i]
		)


func board_is_valid() -> bool:

	for character in characters:

		if !board.can_reach_goal(character):
			return false

	return true


func spawn_characters():

	for character in characters:

		character.spawn(character.current_cell)

		board.set_occupant(
			character.current_cell,
			character
		)


func spawn_scroll():

	scroll.setup(board)

	scroll.spawn(
		board.get_random_scroll_cell()
	)
