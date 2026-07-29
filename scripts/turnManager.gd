extends Node

class_name TurnManager


var turn := 1

var board: BoardState = null
var message_manager: MessageManager = null

var robot: Character = null
var characters: Array[Character] = []

var robot_actions := 0
var pieces_acted: Array[Character] = []


func setup(
	board_state: BoardState,
	message_manager_node: MessageManager,
	robot_character: Character,
	character_list: Array[Character]
):

	board = board_state
	message_manager = message_manager_node

	robot = robot_character
	characters = character_list

	turn = 1
	robot_actions = 0
	pieces_acted.clear()


func can_act(piece: Character) -> bool:

	if piece == null:
		return false

	if !piece.alive:
		return false

	if piece == robot:

		if turn % 2 != 0:

			print("El Robot está recargando.")
			return false

		if robot_actions >= 3:
			return false

		return true

	return piece not in pieces_acted


func register_action(piece: Character):

	if piece == null:
		return

	if !piece.alive:
		return

	if piece == robot:

		robot_actions += 1
		return

	if piece not in pieces_acted:

		pieces_acted.append(piece)


func remove_character(piece: Character):

	if piece == null:
		return

	pieces_acted.erase(piece)

	characters.erase(piece)

	if piece == robot:

		robot = null


func get_required_actions() -> int:

	var required := 0

	for character in characters:

		if !character.alive:
			continue

		if character == robot:

			if turn % 2 == 0:

				required += 3

		else:

			required += 1

	return required


func get_current_actions() -> int:

	return pieces_acted.size() + robot_actions


func has_available_actions() -> bool:

	for character in characters:

		if !can_act(character):
			continue

		if !character.get_possible_moves().is_empty():
			return true

		if message_manager.can_use_show(character):
			return true

	return false


func should_end_turn() -> bool:

	if get_current_actions() >= get_required_actions():
		return true

	# Si ningún personaje puede realizar ninguna acción,
	# el turno termina automáticamente.
	if !has_available_actions():
		return true

	return false


func end_turn():

	turn += 1

	pieces_acted.clear()
	robot_actions = 0

	if turn % 4 == 0:

		board.destroy_next_columns(2)

	print("Turno:", turn)
