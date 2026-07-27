extends Node

class_name BoardState


const ROWS := 25
const COLUMNS := 10


var grid: Dictionary = {}

var ground_tile: TileMapLayer
var obstacle_tile: TileMapLayer


# =====================================
# SETUP
# =====================================

func setup(
	ground_layer: TileMapLayer,
	obstacle_layer: TileMapLayer
):

	ground_tile = ground_layer
	obstacle_tile = obstacle_layer


func create_board():

	grid.clear()

	ground_tile.clear()

	for x in range(ROWS):

		for y in range(COLUMNS):

			var cell := Vector2i(x, y)

			grid[cell] = {
				"type": "Ground",
				"occupant": null,
				"obstacle": false
			}

			ground_tile.set_cell(
				cell,
				0,
				Vector2i(0, 0),
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


# =====================================
# OCUPANTES
# =====================================

func is_occupied(cell: Vector2i) -> bool:

	if !is_inside_board(cell):
		return false

	return grid[cell]["occupant"] != null


func get_occupant(cell: Vector2i):

	if !is_inside_board(cell):
		return null

	return grid[cell]["occupant"]


func set_occupant(
	cell: Vector2i,
	unit
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

	var unit = grid[old_cell]["occupant"]

	grid[old_cell]["occupant"] = null
	grid[new_cell]["occupant"] = unit


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

	obstacle_tile.set_cell(
		cell,
		3,
		Vector2i(0, 0),
		0
	)


func remove_obstacle(cell: Vector2i):

	if !is_inside_board(cell):
		return

	grid[cell]["obstacle"] = false

	obstacle_tile.erase_cell(cell)


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

			visited[next] = true
			queue.append(next)

	return false


func get_random_scroll_cell() -> Vector2i:

	while true:

		var cell := Vector2i(
			randi_range(3, 19),
			randi_range(0, COLUMNS - 1)
		)

		if has_obstacle(cell):
			continue

		if is_occupied(cell):
			continue

		return cell

	return Vector2i.ZERO
