extends TileMapLayer

const ROWS := 25
const COLUMNS := 10

var obstacles := {}


func crear_obstaculos():

	obstacles.clear()
	clear()

	for x in range(ROWS):
		for y in range(COLUMNS):

			obstacles[Vector2i(x, y)] = false

	generar_obstaculos()


func generar_obstaculos():

	var cantidad := 10
	var colocados := 0

	while colocados < cantidad:

		var cell := Vector2i(
			randi_range(3, 23),   # Columnas 4 a 24
			randi_range(0, 9)     # Filas
		)

		if has_obstacle(cell):
			continue

		add_obstacle(cell)
		colocados += 1


func is_inside_board(cell: Vector2i) -> bool:

	return (
		cell.x >= 0
		and cell.x < ROWS
		and cell.y >= 0
		and cell.y < COLUMNS
	)


func has_obstacle(cell: Vector2i) -> bool:

	if !is_inside_board(cell):
		return false

	return obstacles[cell]


func add_obstacle(cell: Vector2i):

	if !is_inside_board(cell):
		return

	obstacles[cell] = true

	# Tile ID 3
	set_cell(cell, 3, Vector2i(0, 0), 0)


func remove_obstacle(cell: Vector2i):

	if !is_inside_board(cell):
		return

	obstacles[cell] = false
	erase_cell(cell)
