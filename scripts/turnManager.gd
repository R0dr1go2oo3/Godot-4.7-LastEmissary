extends Node

class_name TurnManager


var turn := 1

var robot: Character = null

var robot_actions := 0
var pieces_acted: Array[Character] = []


func setup(robot_character: Character):

	robot = robot_character

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

	if piece == robot:

		robot = null


func get_required_actions() -> int:

	if turn % 2 != 0:
		return 3

	return 6


func get_current_actions() -> int:

	return pieces_acted.size() + robot_actions


func should_end_turn() -> bool:

	return get_current_actions() >= get_required_actions()


func end_turn():

	turn += 1

	pieces_acted.clear()
	robot_actions = 0

	print("Turno:", turn)
