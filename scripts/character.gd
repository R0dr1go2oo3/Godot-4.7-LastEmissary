extends Node2D

class_name Character


@export var max_health := 1
@export var moves_per_turn := 1
@export var can_carry_message := true


var health := 0
var has_message := false

var board: BoardState = null
var current_cell: Vector2i

var selected := false



func setup_board(board_state: BoardState):

	board = board_state



func spawn(cell: Vector2i):

	current_cell = cell

	health = max_health

	update_position()



func update_position():

	if board == null:
		return

	position = board.ground_tile.map_to_local(current_cell)



func move_to(cell: Vector2i) -> bool:

	if board == null:
		return false


	if !board.is_inside_board(cell):
		return false


	if board.has_obstacle(cell):

		print("No puedes moverte sobre un obstáculo")

		return false


	if board.is_occupied(cell):

		print("Casilla ocupada")

		return false


	if cell not in get_possible_moves():

		print("Movimiento inválido")

		return false


	current_cell = cell

	update_position()

	print(name, " movido a ", cell)

	return true



func get_possible_moves() -> Array[Vector2i]:

	return get_possible_moves_from(current_cell)



func get_possible_moves_from(
	_cell: Vector2i,
	_ignore_units := false
) -> Array[Vector2i]:

	return []



func take_damage(amount: int):

	health -= amount

	print(name, " recibe ", amount, " de daño. Vida: ", health)


	if health <= 0:

		die()



func heal(amount: int):

	health = min(
		health + amount,
		max_health
	)



func die():

	if board != null:

		board.remove_occupant(current_cell)


	print(name, " ha muerto")

	queue_free()



func pick_message():

	if can_carry_message:

		has_message = true



func drop_message():

	has_message = false
