extends Node2D

class_name Character

signal died(character: Character)


@export var max_health := 1
@export var actions_per_turn := 1
@export var can_carry_message := true


@export_range(50.0, 1000.0, 10.0)
var pixels_per_second := 350.0


var health := 0
var has_message := false

# Protección temporal contra el siguiente golpe.
var protection := false

var board: BoardState = null
var current_cell: Vector2i

var selected := false
var alive := true


func setup_board(board_state: BoardState):

	board = board_state


func spawn(cell: Vector2i):

	current_cell = cell

	health = max_health
	alive = true
	has_message = false
	protection = false

	update_position()


func update_position():

	if board == null:
		return

	position = board.ground_tile.map_to_local(current_cell)


func animate_to_position():

	if board == null:
		return

	var target := board.ground_tile.map_to_local(current_cell)

	var distance := position.distance_to(target)

	var duration := distance / pixels_per_second

	var tween := create_tween()

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		self,
		"position",
		target,
		duration
	)


func move_to(cell: Vector2i) -> bool:

	if !alive:
		return false

	if board == null:
		return false

	if !board.is_inside_board(cell):
		return false

	if board.has_obstacle(cell):

		board.add_log("No puedes moverte sobre un obstáculo.")
		return false

	if board.is_occupied(cell):

		board.add_log("Casilla ocupada.")
		return false

	if cell not in get_possible_moves():

		board.add_log("Movimiento inválido.")
		return false

	current_cell = cell

	animate_to_position()

	board.add_log(
		name + " movido a " + str(cell)
	)

	return true


func get_possible_moves() -> Array[Vector2i]:

	return get_possible_moves_from(current_cell)


func get_possible_moves_from(
	_cell: Vector2i,
	_ignore_units := false
) -> Array[Vector2i]:

	return []


# =====================================
# VIDA
# =====================================

func take_damage(amount: int):

	if !alive:
		return

	if protection:

		protection = false

		board.add_log(
			name + " bloqueó el ataque."
		)

		return

	health -= amount

	board.add_log(
		name + " recibe "
		+ str(amount)
		+ " de daño. Vida: "
		+ str(health)
	)

	if health <= 0:

		die()


func heal(amount: int):

	if !alive:
		return

	health = min(
		health + amount,
		max_health
	)


func die():

	if !alive:
		return

	alive = false
	protection = false

	drop_message()

	if board != null:

		board.remove_occupant(current_cell)

	selected = false

	board.add_log(
		name + " ha muerto."
	)

	died.emit(self)


# =====================================
# MENSAJE
# =====================================

func is_carrier() -> bool:

	return has_message


func pick_message() -> bool:

	if !can_carry_message:
		return false

	if has_message:
		return false

	has_message = true

	return true


func drop_message() -> bool:

	if !has_message:
		return false

	has_message = false

	return true


func show_message() -> bool:

	if !has_message:

		board.add_log(
			name + " no es portador."
		)

		return false

	return true
