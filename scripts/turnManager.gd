extends Node

class_name TurnManager


var turn := 1

var board: BoardState = null

var robot: Character = null
var characters: Array[Character] = []

var robot_actions := 0
var pieces_acted: Array[Character] = []


func setup(
	board_state: BoardState,
	robot_character: Character,
	character_list: Array[Character]
):

	board = board_state

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

			board.add_log("El Robot está recargando.")
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


func end_turn():

	turn += 1

	pieces_acted.clear()
	robot_actions = 0

	# Limpia cualquier elemento que haya quedado
	# por error en zonas destruidas.
	board.cleanup_destroyed_cells()

	if turn % 4 == 0:

		board.destroy_next_columns(2)

	board.add_log("Comienza el turno " + str(turn) + ".")


# =====================================
# HUD
# =====================================

func get_characters() -> Array[Character]:

	return characters


func has_acted(character: Character) -> bool:

	if character == null:
		return false

	if !character.alive:
		return true

	if character == robot:

		if turn % 2 != 0:
			return true

		return robot_actions >= 3

	return character in pieces_acted


func get_robot_actions() -> int:

	return robot_actions
