extends Character

class_name Ninja

const STEALTH_COOLDOWN := 5

# ---------------------------------
# Sigilo
# ---------------------------------

# Puede volver a usar la habilidad.
var stealth_ready := true

# Se activó la habilidad.
# El siguiente movimiento entrará en Sigilo.
var stealth_prepared := false

# El Ninja está oculto.
# Permanece así hasta realizar otro movimiento.
var stealth_active := false

# Movimientos restantes para recuperar la habilidad.
var stealth_steps_left := 0


func can_use_stealth() -> bool:

	return stealth_ready \
		and !stealth_prepared \
		and !stealth_active


func activate_stealth() -> bool:

	if !can_use_stealth():
		return false

	stealth_ready = false
	stealth_prepared = true

	return true


func finish_move():

	# ---------------------------------
	# Entrar en Sigilo
	# ---------------------------------

	if stealth_prepared:

		stealth_prepared = false
		stealth_active = true

		return

	# ---------------------------------
	# Salir del Sigilo
	# ---------------------------------

	if stealth_active:

		stealth_active = false
		stealth_steps_left = STEALTH_COOLDOWN

		return

	# ---------------------------------
	# Reducir recarga
	# ---------------------------------

	if stealth_steps_left > 0:

		stealth_steps_left -= 1

		if stealth_steps_left == 0:

			stealth_ready = true


func is_hidden() -> bool:

	return stealth_active


func get_stealth_status() -> String:

	if stealth_active:

		return "Oculto"

	if stealth_prepared:

		return "Sigilo preparado"

	if stealth_ready:

		return "Sigilo listo"

	return "Sigilo listo en %d pasos" % stealth_steps_left


func get_possible_moves_from(
	cell: Vector2i,
	ignore_units := false
) -> Array[Vector2i]:

	var moves: Array[Vector2i] = []

	var directions: Array[Vector2i] = [
		Vector2i(1, 1),
		Vector2i(1, -1),
		Vector2i(-1, 1),
		Vector2i(-1, -1)
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

		# Enemigo a una casilla:
		# puede atacarlo directamente.
		if board.has_enemy(middle):

			moves.append(middle)
			continue

		# Puede recoger el pergamino antes del salto.
		if board.has_scroll(middle):

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
