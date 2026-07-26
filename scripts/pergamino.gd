extends Node2D

class_name Scroll

var current_cell: Vector2i
var board: BoardState


func setup(board_state: BoardState):

	board = board_state


func spawn(cell: Vector2i):

	current_cell = cell
	position = board.ground_tile.map_to_local(cell)
	visible = true


func collect():

	visible = false
