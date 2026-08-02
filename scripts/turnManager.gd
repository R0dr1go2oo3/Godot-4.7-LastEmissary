extends Node

class_name TurnManager

var turn := 1

var board: BoardState = null

var robot: Robot = null
var characters: Array[Character] = []

var robot_actions := 0
var pieces_acted: Array[Character] = []

# Turnos restantes de recarga del Robot.
# 0 = disponible.
var robot_cooldown := 1


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

	# El Robot comienza disponible
	# en el turno 2.
	robot_cooldown = 1


func can_select(piece: Character) -> bool:

	if piece == null:
		return false

	if !piece.alive:
		return false

	if can_act(piece):
		return true

	if piece is Robot:
		return (piece as Robot).can_use_overload()

	if piece is Ninja:
		return (piece as Ninja).can_use_stealth()

	if piece is Paladin:
		return (piece as Paladin).can_use_protection()

	if piece is Sumo:
		return (piece as Sumo).stomp_ready

	return false


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

		character.protection = false

	if robot != null:

		# Si el Robot actuó este turno,
		# comienza su recarga.
		if robot_actions > 0:

			if robot.overload_active:
				robot_cooldown = 3
			else:
				robot_cooldown = 2

		robot.finish_turn()

	# Reduce la recarga al finalizar el turno.
	if robot_cooldown > 0:

		robot_cooldown -= 1

	board.cleanup_destroyed_cells()

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

	return robot_cooldown > 0


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
