extends Node2D

@onready var game_manager = $manager

@onready var board_state = $boardState

@onready var full_tile: TileMapLayer = $boardState/groundTile
@onready var obstacle_tile: TileMapLayer = $boardState/obstacleTile
@onready var empty_tile: TileMapLayer = $boardState/mouseTile
@onready var select_tile: TileMapLayer = $boardState/movesTile

@onready var paladin: Character = $characters/Paladin
@onready var ninja: Character = $characters/Ninja
@onready var sumo: Character = $characters/Sumo
@onready var robot: Character = $characters/Robot

@onready var scroll: Scroll = $items/pergamino


func _ready():

	var characters: Array[Character] = [
		ninja,
		paladin,
		sumo,
		robot
	]

	game_manager.setup(
		board_state,
		full_tile,
		obstacle_tile,
		empty_tile,
		select_tile,
		characters,
		scroll
	)


func _unhandled_input(event):

	if !(event is InputEventMouseButton):
		return

	if !event.pressed:
		return

	if event.button_index == MOUSE_BUTTON_LEFT:

		var cell: Vector2i = full_tile.local_to_map(
			full_tile.to_local(
				full_tile.get_global_mouse_position()
			)
		)

		game_manager.handle_click(cell)

	elif event.button_index == MOUSE_BUTTON_RIGHT:

		game_manager.handle_right_click()
