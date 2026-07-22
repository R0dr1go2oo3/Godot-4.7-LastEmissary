extends TileMapLayer


func draw_obstacle(cell: Vector2i):

	# Tile ID 3
	set_cell(
		cell,
		3,
		Vector2i(0,0),
		0
	)



func erase_obstacle(cell: Vector2i):

	erase_cell(cell)
