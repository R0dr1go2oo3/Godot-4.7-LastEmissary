extends Node

class_name TurnManager

var turn := 1

var board: BoardState = null

var robot: Robot = null
var characters: Array[Character] = []

var robot_actions := 0
var pieces_acted: Array[Character] = []

# Próximo turno en el que el Robot puede actuar.
var next_robot_turn := 2


func setup(
	board_state: BoardState,
	robot_character: Character,
	character_list: Array[Character]
):

	board = board_state

	robot = robot_character as Robot
	characters = character_list

	turn = 1
	robot_actions = 0
	pieces_acted.clear()

	next_robot_turn = 2


func can_act(piece: Character) -> bool:

	if piece == null:
		return false

	if !piece.alive:
		return false

	if piece == robot:

		if robot_is_recharging():
			return false

		return robot_actions < get_robot_max_actions()

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

	# =====================================
	# Finalizar efectos temporales
	# =====================================

	for character in characters:

		if character == null:
			continue

		if !character.alive:
			continue

		# El escudo dura hasta el inicio
		# del siguiente turno.
		character.protection = false

	if robot != null:

		if turn == next_robot_turn:

			if robot.overload_active:
				next_robot_turn = turn + 3
			else:
				next_robot_turn = turn + 2

		robot.finish_turn()

	# Limpia cualquier elemento que haya quedado
	# por error en zonas destruidas.
	board.cleanup_destroyed_cells()

	# Las columnas se destruyen al FINAL
	# del turno 4, 8, 12...
	if turn % 4 == 0:

		board.destroy_next_columns(2)

	turn += 1

	pieces_acted.clear()
	robot_actions = 0

	board.add_log("Comienza el turno " + str(turn) + ".")


# =====================================
# CONSULTAS
# =====================================

func robot_is_recharging() -> bool:

	return turn < next_robot_turn


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

		if robot_is_recharging():
			return true

		return robot_actions >= get_robot_max_actions()

	return character in pieces_acted


func get_robot_actions() -> int:

	return robot_actions


func get_robot_max_actions() -> int:

	if robot != null and robot.overload_active:
		return 4

	return 3
