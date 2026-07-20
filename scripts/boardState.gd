extends Node


"""const ROWS := 25
const COLUMNS := 10


var grid := {}

var ground_tile: TileMapLayer
var obstacle_tile: TileMapLayer



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
				Vector2i(0,0),
				0
			)



func is_inside_board(cell: Vector2i) -> bool:

	return (
		cell.x >= 0
		and cell.x < ROWS
		and cell.y >= 0
		and cell.y < COLUMNS
	)



# =========================
# OCUPANTES
# =========================


func is_occupied(cell: Vector2i) -> bool:

	if !is_inside_board(cell):
		return false

	return grid[cell]["occupant"] != null



func get_occupant(cell: Vector2i):

	if !is_inside_board(cell):
		return null

	return grid[cell]["occupant"]



func set_occupant(cell: Vector2i, unit):

	if !is_inside_board(cell):
		return

	grid[cell]["occupant"] = unit



func remove_occupant(cell: Vector2i):

	if !is_inside_board(cell):
		return

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



# =========================
# OBSTACULOS
# =========================


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
		Vector2i(0,0),
		0
	)



func remove_obstacle(cell: Vector2i):

	if !is_inside_board(cell):
		return

	grid[cell]["obstacle"] = false

	obstacle_tile.erase_cell(cell)



# =========================
# GENERACION DE OBSTACULOS
# =========================


func create_obstacles():

	clear_obstacles()

	generate_obstacles()



func clear_obstacles():

	for cell in grid:

		grid[cell]["obstacle"] = false

	obstacle_tile.clear()



func generate_obstacles():

	var cantidad := 30
	var colocados := 0


	while colocados < cantidad:

		var cell := Vector2i(
			randi_range(3,23),
			randi_range(0,9)
		)


		if has_obstacle(cell):
			continue


		if column_full(cell.x):
			continue


		add_obstacle(cell)

		colocados += 1



func column_full(column:int) -> bool:

	var count := 0


	for y in range(COLUMNS):

		if has_obstacle(Vector2i(column,y)):
			count += 1


	return count >= COLUMNS - 2"""
