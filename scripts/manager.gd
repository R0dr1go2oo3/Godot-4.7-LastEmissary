extends Node

var board: BoardState

var robot: Character = null
var characters: Array[Character] = []

var selected_character: Character = null

var mouse_tile: TileMapLayer
var moves_tile: TileMapLayer

var scroll: Scroll


@onready var turn_manager: TurnManager = $turnManager
@onready var message_manager: MessageManager = $messageManager
@onready var game_setup: GameSetup = $gameSetup
@onready var enemy_manager: EnemyManager = $enemyManager

# Como logManager es hermano de manager, no hijo.
@onready var log_manager: LogManager = $"../logManager"

# El HUD está en el CanvasLayer.
@onready var hud: HUD = $"../CanvasLayer"


func setup(
	board_state: BoardState,
	ground_tile: TileMapLayer,
	obstacle_tile: TileMapLayer,
	destroyed_tile: TileMapLayer,
	mouse_layer: TileMapLayer,
	moves_layer: TileMapLayer,
	character_list: Array[Character],
	scroll_node: Scroll,
	enemy_container: Node2D,
	torreta_ortogonal_scene: PackedScene,
	torreta_diagonal_scene: PackedScene,
	guerrero_ortogonal_scene: PackedScene,
	guerrero_diagonal_scene: PackedScene,
	jefe_scene: PackedScene
):

	board = board_state

	mouse_tile = mouse_layer
	moves_tile = moves_layer

	board.setup(
		ground_tile,
		obstacle_tile,
		destroyed_tile
	)

	# Configurar sistema de logs.
	log_manager.setup(hud)
	board.setup_log_manager(log_manager)

	characters = character_list

	for character in characters:
		character.died.connect(_on_character_died)

	robot = find_robot()

	scroll = scroll_node

	turn_manager.setup(
		board,
		message_manager,
		robot,
		characters
	)

	message_manager.setup(
		board,
		scroll,
		characters
	)

	enemy_manager.setup(
		board,
		enemy_container,
		torreta_ortogonal_scene,
		torreta_diagonal_scene,
		guerrero_ortogonal_scene,
		guerrero_diagonal_scene,
		jefe_scene
	)

	board.setup_enemy_manager(enemy_manager)
	board.setup_scroll(scroll)

	game_setup.setup(
		board,
		mouse_tile,
		scroll,
		characters,
		enemy_manager
	)

	game_setup.start_game()

	if hud != null:
		update_hud()


func update_hud():

	hud.set_turn(turn_manager.turn)

	var text := ""

	for character in characters:

		if !character.alive:

			text += character.name + " : Muerto\n"
			continue

		if character == robot:

			if turn_manager.turn % 2 != 0:

				text += "Robot : Recargando\n"

			else:

				text += "Robot : %d/3 acciones\n" % turn_manager.get_robot_actions()

		else:

			if turn_manager.has_acted(character):

				text += character.name + " : Ya actuó\n"

			else:

				text += character.name + " : Disponible\n"

	hud.set_actions(text)


func find_robot() -> Character:

	for character in characters:

		if character.name == "Robot":
			return character

	push_error("No se encontró un Robot.")

	return null


func handle_click(cell: Vector2i):

	var piece: Character = board.get_occupant(cell)

	if selected_character == null:

		if piece == null:
			return

		if !turn_manager.can_act(piece):
			return

		select_piece(piece)
		return

	if piece == selected_character:

		deselect()
		return

	if piece != null:

		if !turn_manager.can_act(piece):
			return

		select_piece(piece)
		return

	move_selected(cell)


func handle_right_click():

	if selected_character == null:
		return

	if !turn_manager.can_act(selected_character):
		return

	if !message_manager.use_show(selected_character):
		return

	turn_manager.register_action(selected_character)

	deselect()

	update_hud()

	if turn_manager.should_end_turn():

		turn_manager.end_turn()

		update_hud()

		enemy_manager.enemy_turn()

		update_hud()


func select_piece(piece: Character):

	if selected_character != null:
		selected_character.selected = false

	selected_character = piece
	selected_character.selected = true

	moves_tile.show_moves(
		piece.get_possible_moves()
	)

	board.add_log(
		piece.name + " seleccionado."
	)


func deselect():

	if selected_character == null:
		return

	selected_character.selected = false
	selected_character = null

	moves_tile.clear_moves()


func move_selected(cell: Vector2i):

	if !(cell in selected_character.get_possible_moves()):

		deselect()
		return

	var old_cell := selected_character.current_cell

	if !selected_character.move_to(cell):
		return

	board.move_occupant(
		old_cell,
		selected_character.current_cell
	)

	var enemy: Enemy = board.get_enemy(
		selected_character.current_cell
	)

	if enemy != null:

		enemy.take_damage(enemy.health)

	message_manager.check_scroll(
		selected_character
	)

	check_victory(
		selected_character
	)

	turn_manager.register_action(
		selected_character
	)

	deselect()

	update_hud()

	if turn_manager.should_end_turn():

		turn_manager.end_turn()

		update_hud()

		enemy_manager.enemy_turn()

		update_hud()


func check_victory(character: Character):

	if !character.is_carrier():
		return

	if character.current_cell.x != BoardState.ROWS - 1:
		return

	board.add_log("¡Victoria!")


func _on_character_died(character: Character):

	if character == selected_character:

		deselect()

	turn_manager.remove_character(character)

	if character == robot:

		robot = null

	character.queue_free()

	update_hud()

	check_defeat()


func check_defeat():

	if characters.is_empty():

		board.add_log("¡Derrota!")
