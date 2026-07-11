extends Node2D

func spawn(cell: Vector2i, board: TileMapLayer):
	position = board.map_to_local(cell)
