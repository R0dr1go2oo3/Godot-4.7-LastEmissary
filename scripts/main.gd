extends Node

@onready var full_tile: TileMapLayer = $scenarios/fulltile
@onready var empty_tile: TileMapLayer = $scenarios/emptytile
@onready var select_tile: TileMapLayer = $scenarios/selecttile

var spawn_cells := [
	Vector2i(0, 0),
	Vector2i(0, 3),
	Vector2i(0, 6),
	Vector2i(0, 9)
]

func _ready():

	randomize()

	# Crear el tablero
	full_tile.crear_tablero()

	# El EmptyTile toma como referencia el tablero
	empty_tile.base_layer = full_tile

	# select_tile también usa el tablero
	# select_tile.base_layer = full_tile

	select_tile.pintar_random()

	# Posiciones iniciales aleatorias de los personajes
	spawn_cells.shuffle()

	$characters/ninja.spawn(spawn_cells[0], full_tile)
	$characters/paladin.spawn(spawn_cells[1], full_tile)
	$characters/sumo.spawn(spawn_cells[2], full_tile)
	$characters/robot.spawn(spawn_cells[3], full_tile)
