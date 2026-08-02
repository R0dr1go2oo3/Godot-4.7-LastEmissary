extends Character

class_name Paladin


const PROTECTION_COOLDOWN := 3

# Puede usar el escudo cuando la habilidad está lista.
var protection_ready := true

# Movimientos restantes para recuperar la habilidad.
var protection_steps_left := 0


func can_use_protection() -> bool:

	return alive and protection_ready


func use_protection() -> bool:

	if !can_use_protection():
		return false

	var protected_someone := false

	var directions: Array[Vector2i] = [
		Vector2i.ZERO,
		Vector2i(-1, -1),
		Vector2i(0, -1),
		Vector2i(1, -1),
		Vector2i(-1, 0),
		Vector2i(1, 0),
		Vector2i(-1, 1),
		Vector2i(0, 1),
		Vector2i(1, 1)
	]

	for dir in directions:

		var cell := current_cell + dir

		if !board.is_inside_board(cell):
			continue

		var target := board.get_occupant(cell)

		if target == null:
			continue

		if !target.alive:
			continue

		target.protection = true
		protected_someone = true

		board.add_log(
			target.name + " recibió un escudo."
		)

	if protected_someone:

		protection_ready = false
		protection_steps_left = PROTECTION_COOLDOWN

	return protected_someone


func finish_move():

	if protection_steps_left > 0:

		protection_steps_left -= 1

		if protection_steps_left == 0:

			protection_ready = true


func get_protection_status() -> String:

	if protection_ready:

		return "Escudo listo"

	return "Escudo listo en %d pasos" % protection_steps_left


func get_possible_moves_from(
	cell: Vector2i,
	ignore_units := false
) -> Array[Vector2i]:

	var moves: Array[Vector2i] = []

	var directions: Array[Vector2i] = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1)
	]

	for dir: Vector2i in directions:

		var middle: Vector2i = cell + dir

		if !board.is_inside_board(middle):
			continue

		# No puede atravesar obstáculos.
		if board.has_obstacle(middle):
			continue

		# No puede atravesar personajes.
		if !ignore_units and board.is_occupied(middle):
			continue

		# No puede atravesar casillas destruidas.
		if board.is_destroyed(middle):
			continue

		# Siempre puede detenerse en la casilla intermedia.
		moves.append(middle)

		var target: Vector2i = cell + dir * 2

		# Permitir un salto reducido hacia la meta.
		if dir.x == 1 and target.x == BoardState.ROWS:

			target = Vector2i(
				BoardState.ROWS - 1,
				target.y
			)

		if !board.is_inside_board(target):
			continue

		# No puede caer sobre obstáculos.
		if board.has_obstacle(target):
			continue

		# No puede caer sobre otro personaje.
		if !ignore_units and board.is_occupied(target):
			continue

		# No puede caer sobre casillas destruidas.
		if board.is_destroyed(target):
			continue

		moves.append(target)

	return moves
