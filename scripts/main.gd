extends Node2D

@onready var full_tile: TileMapLayer = $scenarios/fullTile
@onready var empty_tile: TileMapLayer = $scenarios/emptyTile
@onready var select_tile: TileMapLayer = $scenarios/selectTile

@onready var paladin = $characters/Paladin
@onready var ninja = $characters/Ninja
@onready var sumo = $characters/Sumo
@onready var robot = $characters/Robot

var selected_character = null
var characters = []

var turn := 1
var pieces_moved := []

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

	ninja.spawn(spawn_cells[0], full_tile)
	paladin.spawn(spawn_cells[1], full_tile)
	sumo.spawn(spawn_cells[2], full_tile)
	robot.spawn(spawn_cells[3], full_tile)

	characters = [ninja, paladin, sumo, robot]

	print("Turno:", turn)


func _unhandled_input(event):

	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:

		var mouse_global = full_tile.get_global_mouse_position()
		var mouse_local = full_tile.to_local(mouse_global)
		var cell = full_tile.local_to_map(mouse_local)

		# Seleccionar una pieza
		if selected_character == null:

			for character in characters:

				if character in pieces_moved:
					continue

				if character == robot and turn % 2 != 0:
					print("El Robot está recargando")
					continue

				if cell == character.current_cell:
					selected_character = character
					character.selected = true
					print(character.name, " seleccionado")
					break

		# Mover la pieza seleccionada
		else:

			var ocupada := false

			for character in characters:
				if character != selected_character and character.current_cell == cell:
					ocupada = true
					break

			if !ocupada:

				if selected_character.move_to(cell):

					pieces_moved.append(selected_character)

					selected_character.selected = false
					selected_character = null

					var movimientos_necesarios := 4

					# En turnos impares el Robot no juega
					if turn % 2 != 0:
						movimientos_necesarios = 3

					if pieces_moved.size() == movimientos_necesarios:
						turn += 1
						pieces_moved.clear()
						print("Turno:", turn)
