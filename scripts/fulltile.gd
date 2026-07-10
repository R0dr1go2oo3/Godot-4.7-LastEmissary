extends TileMapLayer

const ROWS := 20
const COLUMNS := 10

var grid := {}

func crear_tablero():

	grid.clear()
	clear()

	for x in range(ROWS):
		for y in range(COLUMNS):

			var cell := Vector2i(x, y)

			grid[cell] = {
				"type": "Ground"
			}

			# Tile ID 0
			set_cell(cell, 0, Vector2i(0, 0), 0)
