extends Node2D

@onready var game_manager = $manager

@onready var full_tile: TileMapLayer = $boardState/groundTile
@onready var obstacle_tile: TileMapLayer = $boardState/obstacleTile
@onready var empty_tile: TileMapLayer = $boardState/mouseTile
@onready var select_tile: TileMapLayer = $boardState/movesTile

@onready var paladin = $characters/Paladin
@onready var ninja = $characters/Ninja
@onready var sumo = $characters/Sumo
@onready var robot = $characters/Robot


func _ready():

	game_manager.setup(
		full_tile,
		obstacle_tile,
		empty_tile,
		select_tile,
		[
			ninja,
			paladin,
			sumo,
			robot
		]
	)


func _unhandled_input(event):

	if !(event is InputEventMouseButton):
		return

	if event.button_index != MOUSE_BUTTON_LEFT:
		return

	if !event.pressed:
		return

	var cell: Vector2i = full_tile.local_to_map(
		full_tile.to_local(
			full_tile.get_global_mouse_position()
		)
	)

	game_manager.handle_click(cell)
