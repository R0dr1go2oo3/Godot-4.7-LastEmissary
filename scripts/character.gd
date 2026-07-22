extends Node2D

class_name Character


var board
var current_cell: Vector2i

var selected := false


func spawn(cell: Vector2i, board_state):

	board = board_state
	current_cell = cell

	update_position()


func update_position():

	position = board.ground_tile.map_to_local(current_cell)


func move_to(cell: Vector2i) -> bool:

	if !board.is_inside_board(cell):
		return false

	if board.has_obstacle(cell):
		print("No puedes moverte sobre un obstáculo")
		return false

	if board.is_occupied(cell):
		print("Casilla ocupada")
		return false

	if cell not in get_possible_moves():
		print("Movimiento inválido")
		return false

	current_cell = cell

	update_position()

	print(name, " movido a ", cell)

	return true


func get_possible_moves() -> Array[Vector2i]:

	return []
