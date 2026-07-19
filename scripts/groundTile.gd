extends TileMapLayer

const ROWS := 25
const COLUMNS := 10

var grid := {}

func crear_tablero():

	grid.clear()
	clear()

	for x in range(ROWS):
		for y in range(COLUMNS):

			var cell := Vector2i(x, y)

			grid[cell] = {
				"type": "Ground",
				"occupant": null
			}

			# Tile ID 0
			set_cell(cell, 0, Vector2i(0, 0), 0)


func is_inside_board(cell: Vector2i) -> bool:

	return (
		cell.x >= 0
		and cell.x < ROWS
		and cell.y >= 0
		and cell.y < COLUMNS
	)


func is_occupied(cell: Vector2i) -> bool:

	if !is_inside_board(cell):
		return false

	return grid[cell].occupant != null


func get_occupant(cell: Vector2i):

	if !is_inside_board(cell):
		return null

	return grid[cell].occupant


func add_occupant(cell: Vector2i, piece):

	if is_inside_board(cell):
		grid[cell].occupant = piece


func remove_occupant(cell: Vector2i):

	if is_inside_board(cell):
		grid[cell].occupant = null


func move_occupant(old_cell: Vector2i, new_cell: Vector2i):

	if !is_inside_board(old_cell):
		return

	if !is_inside_board(new_cell):
		return

	var piece = grid[old_cell].occupant

	grid[old_cell].occupant = null
	grid[new_cell].occupant = piece
