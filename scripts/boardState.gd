extends Node

class_name BoardState


const ROWS := 25
const COLUMNS := 10


var grid: Dictionary = {}

var ground_tile: TileMapLayer
var obstacle_tile: TileMapLayer
var destroyed_tile: TileMapLayer

var destroyed_columns := 0

var enemy_manager: EnemyManager
var scroll: Scroll

# Personajes vivos de la partida.
var characters: Array[Character] = []

var log_manager: LogManager


# =====================================
# SETUP
# =====================================

func setup(
	ground_layer: TileMapLayer,
	obstacle_layer: TileMapLayer,
	destroyed_layer: TileMapLayer
):

	ground_tile = ground_layer
	obstacle_tile = obstacle_layer
	destroyed_tile = destroyed_layer


func setup_enemy_manager(manager: EnemyManager):

	enemy_manager = manager


func setup_characters(character_list: Array[Character]):

	characters = character_list


func setup_scroll(scroll_node: Scroll):

	scroll = scroll_node


func setup_log_manager(manager: LogManager):

	log_manager = manager


func add_log(text: String):

	if log_manager != null:

		log_manager.log(text)


func create_board():

	grid.clear()

	ground_tile.clear()
	obstacle_tile.clear()
	destroyed_tile.clear()

	destroyed_columns = 0

	for x in range(ROWS):

		for y in range(COLUMNS):

			var cell := Vector2i(x, y)

			grid[cell] = {
				"type": "Ground",
				"occupant": null,
				"obstacle": false,
				"destroyed": false
			}

			ground_tile.set_cell(
				cell,
				0,
				Vector2i(randi_range(0, 31), 0),
				0
			)


# =====================================
# CELDAS
# =====================================

func is_inside_board(cell: Vector2i) -> bool:

	return (
		cell.x >= 0
		and cell.x < ROWS
		and cell.y >= 0
		and cell.y < COLUMNS
	)


func is_destroyed(cell: Vector2i) -> bool:

	if !is_inside_board(cell):
		return true

	return grid[cell]["destroyed"]


func is_cell_free(cell: Vector2i) -> bool:

	if !is_inside_board(cell):
		return false

	if is_destroyed(cell):
		return false

	if has_obstacle(cell):
		return false

	if is_occupied(cell):
		return false

	if has_enemy(cell):
		return false

	if has_scroll(cell):
		return false

	return true


func get_random_free_cell(
	min_column: int,
	max_column: int
) -> Vector2i:

	var candidates: Array[Vector2i] = []

	for x in range(min_column, max_column + 1):

		for y in range(COLUMNS):

			var cell := Vector2i(x, y)

			if is_cell_free(cell):

				candidates.append(cell)

	if candidates.is_empty():

		push_error("No hay casillas libres.")

		return Vector2i.ZERO

	candidates.shuffle()

	return candidates[0]


func get_adjacent_cells(cell: Vector2i) -> Array[Vector2i]:

	var cells: Array[Vector2i] = []

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

		var target := cell + dir

		if is_inside_board(target):

			cells.append(target)

	return cells


# =====================================
# OCUPANTES
# =====================================

func is_occupied(cell: Vector2i) -> bool:

	if !is_inside_board(cell):
		return false

	return grid[cell]["occupant"] != null


func get_occupant(cell: Vector2i) -> Character:

	if !is_inside_board(cell):
		return null

	return grid[cell]["occupant"] as Character


func set_occupant(
	cell: Vector2i,
	unit: Character
):

	if !is_inside_board(cell):
		return

	grid[cell]["occupant"] = unit


func remove_occupant(cell: Vector2i):

	if !is_inside_board(cell):
		return

	grid[cell]["occupant"] = null


func clear_occupants():

	for cell in grid:

		grid[cell]["occupant"] = null


func move_occupant(
	old_cell: Vector2i,
	new_cell: Vector2i
):

	if !is_inside_board(old_cell):
		return

	if !is_inside_board(new_cell):
		return

	var unit: Character = grid[old_cell]["occupant"] as Character

	grid[old_cell]["occupant"] = null
	grid[new_cell]["occupant"] = unit


# =====================================
# ENEMIGOS
# =====================================

func has_enemy(cell: Vector2i) -> bool:

	if enemy_manager == null:
		return false

	return enemy_manager.has_enemy(cell)


func get_enemy(cell: Vector2i) -> Enemy:

	if enemy_manager == null:
		return null

	return enemy_manager.get_enemy_at(cell)


func is_dangerous_for_enemies(cell: Vector2i) -> bool:

	for character in characters:

		if character == null:
			continue

		if !character.alive:
			continue

		if cell in character.get_possible_moves():

			return true

	return false


# =====================================
# PERGAMINO
# =====================================

func has_scroll(cell: Vector2i) -> bool:

	if scroll == null:
		return false

	if !scroll.visible:
		return false

	return scroll.current_cell == cell


# =====================================
# DESTRUCCIÓN
# =====================================

func cleanup_destroyed_cells():

	for cell in grid.keys():

		if !grid[cell]["destroyed"]:
			continue

		if has_obstacle(cell):

			remove_obstacle(cell)

		var character := get_occupant(cell)

		if character != null:

			character.die()

		var enemy := get_enemy(cell)

		if enemy != null:

			enemy.die()

		if has_scroll(cell):

			scroll.collect()


func destroy_next_columns(amount := 2):

	# Limpia cualquier elemento que haya quedado
	# en una zona ya destruida.
	cleanup_destroyed_cells()

	for x in range(
		destroyed_columns,
		min(destroyed_columns + amount, ROWS)
	):

		destroy_column(x)

	destroyed_columns += amount

	add_log(
		"Se destruyeron %d columna(s)." % amount
	)


func destroy_column(column: int):

	for y in range(COLUMNS):

		var cell := Vector2i(column, y)

		grid[cell]["destroyed"] = true

		ground_tile.erase_cell(cell)
		obstacle_tile.erase_cell(cell)

		destroyed_tile.set_cell(
			cell,
			4,
			Vector2i.ZERO,
			0
		)

		if has_obstacle(cell):

			remove_obstacle(cell)

		var character := get_occupant(cell)

		if character != null:

			character.die()

		var enemy := get_enemy(cell)

		if enemy != null:

			enemy.die()

		if has_scroll(cell):

			scroll.collect()


# =====================================
# OBSTÁCULOS
# =====================================

func has_obstacle(cell: Vector2i) -> bool:

	if !is_inside_board(cell):
		return false

	return grid[cell]["obstacle"]


func add_obstacle(cell: Vector2i):

	if !is_inside_board(cell):
		return

	grid[cell]["obstacle"] = true

	var variants: Array[Vector2i] = [
		Vector2i(0, 0),
		Vector2i(1, 0)
	]

	obstacle_tile.set_cell(
		cell,
		3,
		variants.pick_random(),
		0
	)


func remove_obstacle(cell: Vector2i):

	if !is_inside_board(cell):
		return

	grid[cell]["obstacle"] = false

	obstacle_tile.erase_cell(cell)


func destroy_obstacle(cell: Vector2i):

	if !is_inside_board(cell):
		return

	if !has_obstacle(cell):
		return

	remove_obstacle(cell)

	add_log(
		"Un obstáculo fue destruido."
	)


func create_obstacles():

	clear_obstacles()

	generate_obstacles()


func clear_obstacles():

	for cell in grid:

		grid[cell]["obstacle"] = false

	obstacle_tile.clear()


func generate_obstacles():

	var amount := 30
	var placed := 0

	while placed < amount:

		var cell := Vector2i(
			randi_range(3, 23),
			randi_range(0, 9)
		)

		if has_obstacle(cell):
			continue

		if column_full(cell.x):
			continue

		add_obstacle(cell)

		placed += 1


func column_full(column: int) -> bool:

	var obstacles := 0

	for y in range(COLUMNS):

		if has_obstacle(Vector2i(column, y)):
			obstacles += 1

	return obstacles >= COLUMNS - 2


# =====================================
# UTILIDADES
# =====================================

func can_reach_goal(character: Character) -> bool:

	var visited: Dictionary = {}
	var queue: Array[Vector2i] = []

	queue.append(character.current_cell)
	visited[character.current_cell] = true

	while !queue.is_empty():

		var current: Vector2i = queue.pop_front()

		if current.x == ROWS - 1:
			return true

		var moves: Array[Vector2i] = character.get_possible_moves_from(
			current,
			true
		)

		for next: Vector2i in moves:

			if visited.has(next):
				continue

			if is_destroyed(next):
				continue

			visited[next] = true
			queue.append(next)

	return false


func get_random_scroll_cell() -> Vector2i:

	return get_random_free_cell(
		5,
		15
	)
