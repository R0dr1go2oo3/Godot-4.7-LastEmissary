extends Node

class_name TurnManager


var turn := 1

var robot: Character

var robot_actions := 0
var pieces_acted: Array[Character] = []


func setup(robot_character: Character):

	robot = robot_character


func can_act(piece: Character) -> bool:

	if piece == robot:

		if turn % 2 != 0:

			print("El Robot está recargando.")
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


func get_required_actions() -> int:

	if turn % 2 != 0:
		return 3

	return 6


func get_current_actions() -> int:

	return pieces_acted.size() + robot_actions


func end_turn():

	turn += 1

	pieces_acted.clear()
	robot_actions = 0

	print("Turno:", turn)


func should_end_turn() -> bool:

	return get_current_actions() >= get_required_actions()
