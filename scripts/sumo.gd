extends Character

class_name Sumo


const STOMP_COOLDOWN := 10

var stomp_ready := true
var stomp_steps_left := 0


func get_stomp_status() -> String:

	if stomp_ready:

		return "Pisotón listo"

	return "Pisotón listo en %d pasos" % stomp_steps_left


func use_stomp() -> bool:

	if !alive:
		return false

	if !stomp_ready:
		return false

	stomp_ready = false
	stomp_steps_left = STOMP_COOLDOWN

	var affected := false

	var directions: Array[Vector2i] = [
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

		# Destruir obstáculo.
		if board.has_obstacle(cell):

			board.destroy_obstacle(cell)
			affected = true

		# Matar enemigo.
		var enemy := board.get_enemy(cell)

		if enemy != null:

			enemy.take_damage(enemy.health)
			affected = true

	if !affected:

		# No gastar la habilidad si no afectó nada.
		stomp_ready = true
		stomp_steps_left = 0

	return affected


func finish_move():

	if stomp_steps_left > 0:

		stomp_steps_left -= 1

		if stomp_steps_left == 0:

			stomp_ready = true


func get_possible_moves_from(
	cell: Vector2i,
	_ignore_units := false
) -> Array[Vector2i]:

	var moves: Array[Vector2i] = []

	var directions: Array[Vector2i] = [
		Vector2i(-1, -1),
		Vector2i(0, -1),
		Vector2i(1, -1),
		Vector2i(-1, 0),
		Vector2i(1, 0),
		Vector2i(-1, 1),
		Vector2i(0, 1),
		Vector2i(1, 1)
	]

	for dir: Vector2i in directions:

		var first: Vector2i = cell + dir

		if !board.is_inside_board(first):
			continue

		var second: Vector2i = first + dir

		# =====================================
		# CASILLA VACÍA
		# =====================================

		if !board.has_obstacle(first) \
		and !board.is_occupied(first) \
		and !board.has_enemy(first):

			moves.append(first)
			continue

		# =====================================
		# ENEMIGO
		# =====================================

		if board.has_enemy(first):

			# Puede matar al primero quedándose en su casilla.
			moves.append(first)

			if !board.is_inside_board(second):
				continue

			# No puede saltar dos obstáculos.
			if board.has_obstacle(second):
				continue

			# No puede terminar sobre un compañero.
			if board.is_occupied(second):
				continue

			# Puede caer sobre vacío o enemigo.
			moves.append(second)

			continue

		# =====================================
		# COMPAÑERO
		# =====================================

		if board.is_occupied(first):

			if !board.is_inside_board(second):
				continue

			if board.has_obstacle(second):
				continue

			if board.is_occupied(second):
				continue

			# Puede caer sobre vacío o enemigo.
			moves.append(second)

			continue

		# =====================================
		# OBSTÁCULO
		# =====================================

		if board.has_obstacle(first):

			if !board.is_inside_board(second):
				continue

			# No puede saltar dos obstáculos.
			if board.has_obstacle(second):
				continue

			# No puede caer sobre un compañero.
			if board.is_occupied(second):
				continue

			# Puede caer sobre vacío o enemigo.
			moves.append(second)

	return moves


func move_to(cell: Vector2i) -> bool:

	if !alive:
		return false

	if board == null:
		return false

	if !board.is_inside_board(cell):
		return false

	if board.has_obstacle(cell):
		return false

	if board.is_occupied(cell):
		return false

	if cell not in get_possible_moves():
		return false

	var direction: Vector2i = Vector2i(
		sign(cell.x - current_cell.x),
		sign(cell.y - current_cell.y)
	)

	var distance: int = maxi(
		abs(cell.x - current_cell.x),
		abs(cell.y - current_cell.y)
	)

	# =====================================
	# CASILLA INTERMEDIA
	# =====================================

	if distance == 2:

		var middle: Vector2i = current_cell + direction

		var enemy: Enemy = board.get_enemy(middle)

		if enemy != null:

			enemy.take_damage(enemy.health)

	# =====================================
	# CASILLA DESTINO
	# =====================================

	var target_enemy: Enemy = board.get_enemy(cell)

	if target_enemy != null:

		target_enemy.take_damage(target_enemy.health)

	current_cell = cell

	animate_to_position()

	board.add_log(
		name + " movido a " + str(cell)
	)

	return true
