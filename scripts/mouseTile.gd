extends TileMapLayer

class_name MouseTile

@export var ground_tile: TileMapLayer
@export var board: BoardState

var last_cell := Vector2i(99999, 99999)
var painted_attack_cells: Array[Vector2i] = []


func _process(_delta):

	if ground_tile == null:
		return

	var mouse_local := ground_tile.to_local(get_global_mouse_position())
	var cell := ground_tile.local_to_map(mouse_local)

	if cell == last_cell:
		return

	# Limpiar cursor anterior.
	if last_cell != Vector2i(99999, 99999):
		erase_cell(last_cell)

	# Limpiar rango enemigo anterior.
	for attack_cell in painted_attack_cells:
		erase_cell(attack_cell)

	painted_attack_cells.clear()

	# Tile ID 1: cursor.
	set_cell(cell, 1, Vector2i(0, 0), 0)

	last_cell = cell

	if board == null:
		return

	var enemy := board.get_enemy(cell)

	if enemy == null:
		return

	for attack_cell in enemy.get_attack_cells():

		# No pintar fuera del tablero.
		if !board.is_inside_board(attack_cell):
			continue

		# Mantener visible el cursor.
		if attack_cell == cell:
			continue

		# No pintar sobre obstáculos.
		if board.has_obstacle(attack_cell):
			continue

		# No pintar sobre otros enemigos.
		if board.has_enemy(attack_cell):
			continue

		# Tile ID 5: rango enemigo.
		set_cell(
			attack_cell,
			5,
			Vector2i(0, 0),
			0
		)

		painted_attack_cells.append(attack_cell)
