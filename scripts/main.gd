extends Node

@onready var full_tile: TileMapLayer = $fulltile
@onready var empty_tile: TileMapLayer = $emptytile
@onready var select_tile: TileMapLayer = $selecttile

func _ready():

	randomize()

	# Crear el tablero
	full_tile.crear_tablero()

	# El EmptyTile toma como referencia el tablero
	empty_tile.base_layer = full_tile
	
	select_tile.pintar_random()
	# Si después SelectTile también necesita saber cuál es el tablero:
	# select_tile.base_layer = full_tile
