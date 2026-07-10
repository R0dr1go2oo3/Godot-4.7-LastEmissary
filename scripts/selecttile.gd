extends TileMapLayer

func pintar_random():
	var cell := Vector2i(
		randi_range(0, 19),
		randi_range(0, 9)
	)

	set_cell(cell, 2, Vector2i.ZERO)

	print("SelectTile ejecutado: (", cell.x+1,", ", cell.y+1,")")
