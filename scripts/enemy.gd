extends Node2D

class_name Enemy


@export var max_health := 1
@export var actions_per_turn := 2


var health := 0
var alive := true

var board: BoardState = null
var current_cell: Vector2i


func setup_board(board_state: BoardState):

	board = board_state


func spawn(cell: Vector2i):

	current_cell = cell

	health = max_health
	alive = true

	update_position()


func update_position():

	if board == null:
		return

	position = board.ground_tile.map_to_local(current_cell)


func can_move(cell: Vector2i) -> bool:

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

	if board.has_enemy(cell):
		return false

	return true


func move_to(cell: Vector2i) -> bool:

	if !can_move(cell):
		return false

	current_cell = cell

	update_position()

	return true


func get_possible_moves() -> Array[Vector2i]:

	return get_possible_moves_from(current_cell)


func get_possible_moves_from(
	_cell: Vector2i
) -> Array[Vector2i]:

	return []


func get_attack_cells() -> Array[Vector2i]:

	return get_attack_cells_from(current_cell)


func get_attack_cells_from(
	_cell: Vector2i
) -> Array[Vector2i]:

	return []


func has_target() -> bool:

	for cell in get_attack_cells():

		var character: Character = board.get_occupant(cell)

		if character != null:

			return true

	return false


func can_attack(character: Character) -> bool:

	if !alive:
		return false

	if character == null:
		return false

	return character.current_cell in get_attack_cells()


func attack():

	pass


func take_turn():

	pass


func take_damage(amount: int):

	if !alive:
		return

	health -= amount

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

	if board != null:

		var enemy := board.get_enemy(current_cell)

		if enemy != null:

			board.enemy_manager.remove_enemy(enemy)

	print(name, " ha muerto.")
