extends Node2D

@onready var full_tile: TileMapLayer = $scenarios/fullTile
@onready var empty_tile: TileMapLayer = $scenarios/emptyTile
@onready var select_tile: TileMapLayer = $scenarios/selectTile

@onready var paladin = $characters/Paladin

var selected_character = null

var spawn_cells := [
	Vector2i(0, 0),
	Vector2i(0, 3),
	Vector2i(0, 6),
	Vector2i(0, 9)
]

func _ready():

	randomize()

	full_tile.crear_tablero()

	empty_tile.base_layer = full_tile

	select_tile.pintar_random()

	spawn_cells.shuffle()

	$characters/Ninja.spawn(spawn_cells[0], full_tile)
	paladin.spawn(spawn_cells[1], full_tile)
	$characters/Sumo.spawn(spawn_cells[2], full_tile)
	$characters/Robot.spawn(spawn_cells[3], full_tile)


func _unhandled_input(event):

	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:

		var mouse_global = full_tile.get_global_mouse_position()
		var mouse_local = full_tile.to_local(mouse_global)
		var cell = full_tile.local_to_map(mouse_local)

		# Seleccionar el paladín
		if selected_character == null:

			if cell == paladin.current_cell:
				selected_character = paladin
				paladin.selected = true
				print("Paladín seleccionado")

		# Mover el paladín
		else:

			selected_character.move_to(cell)
			selected_character.selected = false
			selected_character = null
