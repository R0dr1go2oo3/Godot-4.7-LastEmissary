extends CanvasLayer

class_name HUD


@onready var turn_label: Label = $PanelContainer/HBoxContainer/VBoxContainerL/turnLabel
@onready var actions_label: RichTextLabel = $PanelContainer/HBoxContainer/VBoxContainerL/actionsLabel
@onready var log_label: RichTextLabel = $PanelContainer/HBoxContainer/VBoxContainerR/log


func _ready() -> void:

	if turn_label == null:
		push_error("No se encontró turnLabel.")

	if actions_label == null:
		push_error("No se encontró actionsLabel.")

	if log_label == null:
		push_error("No se encontró log.")


func set_turn(turn: int) -> void:

	if turn_label == null:
		return

	turn_label.text = "Turno: " + str(turn)


func set_actions(text: String) -> void:

	if actions_label == null:
		return

	actions_label.text = text


func add_log(text: String) -> void:

	if log_label == null:
		return

	log_label.append_text(text + "\n")

	# Mantiene visible la última acción del historial.
	log_label.scroll_to_line(log_label.get_line_count())


func clear_log() -> void:

	if log_label == null:
		return

	log_label.clear()
