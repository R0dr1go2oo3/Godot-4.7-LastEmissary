extends Node

class_name LogManager


const MAX_LINES := 15


var hud: HUD = null

var history: Array[String] = []


func setup(hud_node: HUD):

	hud = hud_node


func log(text: String):

	print(text)

	history.append(text)

	while history.size() > MAX_LINES:

		history.remove_at(0)

	update_hud()


func clear():

	history.clear()

	update_hud()


func get_history() -> Array[String]:

	return history.duplicate()


func update_hud():

	if hud == null:
		return

	hud.clear_log()

	for line in history:

		hud.add_log(line)
