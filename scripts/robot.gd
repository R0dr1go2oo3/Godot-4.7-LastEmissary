extends Character

class_name Robot

# ----------------------------
# Sobrecarga
# ----------------------------

var overload_active := false


func can_use_overload() -> bool:

	return !overload_active


func activate_overload() -> bool:

	if !can_use_overload():
		return false

	overload_active = true

	return true


func finish_turn():

	overload_active = false


func get_overload_status() -> String:

	if overload_active:

		return "Sobrecarga activa"

	return "Sobrecarga lista"


func get_possible_moves_from(
	cell: Vector2i,
	ignore_units := false
) -> Array[Vector2i]:

	var moves: Array[Vector2i] = []

	var directions := [
		Vector2i(-1, -1),
		Vector2i(0, -1),
		Vector2i(1, -1),
		Vector2i(-1, 0),
		Vector2i(1, 0),
		Vector2i(-1, 1),
		Vector2i(0, 1),
		Vector2i(1, 1)
	]

	for dir: Vector2i in directions:

		var target := cell + dir

		if !board.is_inside_board(target):
			continue

		if board.has_obstacle(target):
			continue

		if !ignore_units and board.is_occupied(target):
			continue

		moves.append(target)

	return moves
