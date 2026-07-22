extends TileMapLayer


const ROWS := 25
const COLUMNS := 10


func draw_board():

	clear()

	for x in range(ROWS):

		for y in range(COLUMNS):

			var cell := Vector2i(x, y)

			# Tile ID 0
			set_cell(
				cell,
				0,
				Vector2i(0,0),
				0
			)
