extends Node2D

@onready var full_tile: TileMapLayer = $scenarios/groundTile
@onready var obstacle_tile: TileMapLayer = $scenarios/obstacleTile
@onready var empty_tile: TileMapLayer = $scenarios/mouseTile
@onready var select_tile: TileMapLayer = $scenarios/movesTile

@onready var paladin = $characters/Paladin
@onready var ninja = $characters/Ninja
@onready var sumo = $characters/Sumo
@onready var robot = $characters/Robot

var robot_moves := 0

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

	# NUEVO
	full_tile.obstacle_layer = obstacle_tile

	obstacle_tile.crear_obstaculos()

	empty_tile.base_layer = full_tile

	spawn_cells.shuffle()

	ninja.spawn(spawn_cells[0], full_tile)
	paladin.spawn(spawn_cells[1], full_tile)
	sumo.spawn(spawn_cells[2], full_tile)
	robot.spawn(spawn_cells[3], full_tile)

	full_tile.add_occupant(ninja.current_cell, ninja)
	full_tile.add_occupant(paladin.current_cell, paladin)
	full_tile.add_occupant(sumo.current_cell, sumo)
	full_tile.add_occupant(robot.current_cell, robot)

	characters = [ninja, paladin, sumo, robot]

	print("Turno:", turn)


func _unhandled_input(event):

	if !(event is InputEventMouseButton):
		return

	if event.button_index != MOUSE_BUTTON_LEFT or !event.pressed:
		return

	var mouse_global = full_tile.get_global_mouse_position()
	var mouse_local = full_tile.to_local(mouse_global)
	var cell = full_tile.local_to_map(mouse_local)

	var piece = full_tile.get_occupant(cell)

	# =====================================================
	# NO HAY NINGUNA PIEZA SELECCIONADA
	# =====================================================

	if selected_character == null:

		if piece == null:
			return

		if piece == robot:

			if turn % 2 != 0:
				print("El Robot está recargando")
				return

			if robot_moves >= 3:
				return

		elif piece in pieces_moved:
			return

		selected_character = piece
		selected_character.selected = true

		select_tile.show_moves(selected_character.get_possible_moves())

		print(selected_character.name, " seleccionado")

		return

	# =====================================================
	# YA HAY UNA PIEZA SELECCIONADA
	# =====================================================

	# Clic sobre la misma pieza -> deseleccionar
	if piece == selected_character:

		selected_character.selected = false
		selected_character = null
		select_tile.clear_moves()

		return

	# Clic sobre otra pieza -> cambiar selección
	if piece != null:

		if piece == robot:

			if turn % 2 != 0:
				print("El Robot está recargando")
				return

			if robot_moves >= 3:
				return

		elif piece in pieces_moved:
			return

		selected_character.selected = false

		selected_character = piece
		selected_character.selected = true

		select_tile.show_moves(selected_character.get_possible_moves())

		print(selected_character.name, " seleccionado")

		return

	# Clic en una casilla vacía

	# Si es un movimiento válido, mover.
	if cell in selected_character.get_possible_moves():

		var old_cell: Vector2i = selected_character.current_cell

		if selected_character.move_to(cell):

			full_tile.move_occupant(
				old_cell,
				selected_character.current_cell
			)

			if selected_character == robot:
				robot_moves += 1
			else:
				pieces_moved.append(selected_character)

			selected_character.selected = false
			selected_character = null

			select_tile.clear_moves()

			var movimientos_necesarios := 6

			if turn % 2 != 0:
				movimientos_necesarios = 3

			var acciones := pieces_moved.size() + robot_moves

			if acciones == movimientos_necesarios:

				turn += 1
				pieces_moved.clear()
				robot_moves = 0

				print("Turno:", turn)

		return

	# Si la casilla vacía NO es un movimiento válido, deseleccionar.
	selected_character.selected = false
	selected_character = null

	select_tile.clear_moves()
