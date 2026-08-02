extends Node

var board: BoardState

var robot: Robot = null
var characters: Array[Character] = []

var selected_character: Character = null

var mouse_tile: TileMapLayer
var moves_tile: TileMapLayer

var scroll: Scroll
var game_over := false

@onready var turn_manager: TurnManager = $turnManager
@onready var message_manager: MessageManager = $messageManager
@onready var game_setup: GameSetup = $gameSetup
@onready var enemy_manager: EnemyManager = $enemyManager

# Como logManager es hermano de manager, no hijo.
@onready var log_manager: LogManager = $"../logManager"

# El HUD está en el CanvasLayer.
@onready var hud: HUD = $"../HUD"


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

	# Permite que la IA consulte los movimientos
	# de todos los personajes.
	board.setup_characters(characters)

	for character in characters:
		character.died.connect(_on_character_died)

	robot = find_robot()

	scroll = scroll_node

	turn_manager.setup(
		board,
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

		hud.end_turn_pressed.connect(_on_end_turn_pressed)

		update_hud()


func update_hud():

	hud.set_turn(turn_manager.turn)

	var text := ""

	for character in characters:

		if !character.alive:

			text += character.name + " : Muerto\n"
			continue

		if character == robot:

			if turn_manager.robot_is_recharging():

				text += "Robot : Recargando"

			else:

				text += "Robot : %d/%d acciones" % [
					turn_manager.get_robot_actions(),
					turn_manager.get_robot_max_actions()
				]

			text += " | " + robot.get_overload_status()

		elif character is Ninja:

			var ninja := character as Ninja

			if turn_manager.has_acted(character):

				text += "Ninja : Ya actuó"

			else:

				text += "Ninja : Disponible"

			text += " | " + ninja.get_stealth_status()

		elif character is Paladin:

			var paladin := character as Paladin

			if turn_manager.has_acted(character):

				text += "Paladín : Ya actuó"

			else:

				text += "Paladín : Disponible"

			text += " | " + paladin.get_protection_status()

		elif character is Sumo:

			var sumo := character as Sumo

			if turn_manager.has_acted(character):

				text += "Sumo : Ya actuó"

			else:

				text += "Sumo : Disponible"

			text += " | " + sumo.get_stomp_status()

		else:

			if turn_manager.has_acted(character):

				text += character.name + " : Ya actuó"

			else:

				text += character.name + " : Disponible"

		if character.protection:

			text += " | Escudo"

		if character.is_carrier():

			text += " | Portador"

		text += "\n"

	hud.set_actions(text)


func find_robot() -> Robot:

	for character in characters:

		if character.name == "Robot":
			return character as Robot

	push_error("No se encontró un Robot.")

	return null


func handle_click(cell: Vector2i):

	if game_over:
		return

	var piece: Character = board.get_occupant(cell)

	if selected_character == null:

		if piece == null:
			return

		if !turn_manager.can_select(piece):
			return

		select_piece(piece)
		return

	if piece == selected_character:

		deselect()
		return

	if piece != null:

		if !turn_manager.can_select(piece):
			return

		select_piece(piece)
		return

	move_selected(cell)


func handle_right_click():

	if game_over:
		return

	if selected_character == null:
		return

	if !turn_manager.can_act(selected_character):
		return

	if !message_manager.use_show(selected_character):
		return

	turn_manager.register_action(selected_character)

	deselect()

	update_hud()


func _unhandled_input(event: InputEvent):

	if game_over:
		return

	if !event.is_action_pressed("useHability"):
		return

	if selected_character == null:
		return

	# =====================================
	# Robot
	# =====================================

	if selected_character == robot:

		if robot.activate_overload():

			board.add_log("Robot activa Sobrecarga.")
			update_hud()
			return

		board.add_log(
			robot.get_overload_status()
		)

		return

	# =====================================
	# Ninja
	# =====================================

	if selected_character is Ninja:

		var ninja := selected_character as Ninja

		if ninja.activate_stealth():

			board.add_log("Ninja prepara el Sigilo.")
			update_hud()
			return

		board.add_log(
			ninja.get_stealth_status()
		)

		return

	# =====================================
	# Paladín
	# =====================================

	if selected_character is Paladin:

		var paladin := selected_character as Paladin

		if paladin.use_protection():

			board.add_log(
				"Paladín protegió a los aliados cercanos."
			)

			deselect()

			update_hud()

			return

		if paladin.can_use_protection():

			board.add_log(
				"No hay aliados cercanos para proteger."
			)

		else:

			board.add_log(
				paladin.get_protection_status()
			)

		return

	# =====================================
	# Sumo
	# =====================================

	if selected_character is Sumo:

		var sumo := selected_character as Sumo

		if !sumo.stomp_ready:

			board.add_log(
				sumo.get_stomp_status()
			)

			return

		if !sumo.use_stomp():

			board.add_log(
				"El Pisotón no tuvo efecto."
			)

			return

		board.add_log(
			"Sumo utilizó Pisotón."
		)

		# Temporalmente el Pisotón no consume acción.

		deselect()

		update_hud()

		return


func select_piece(piece: Character):

	if selected_character != null:
		selected_character.selected = false

	selected_character = piece
	selected_character.selected = true

	if turn_manager.can_act(piece):

		moves_tile.show_moves(
			piece.current_cell,
			piece.get_possible_moves()
		)

	else:

		var empty_moves: Array[Vector2i] = []

		moves_tile.show_moves(
			piece.current_cell,
			empty_moves
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

	# Si ya no puede actuar, solo puede usar habilidad.
	if !turn_manager.can_act(selected_character):

		deselect()
		return

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

	# =====================================
	# Ninja
	# =====================================

	if selected_character is Ninja:

		var ninja := selected_character as Ninja

		var was_prepared := ninja.stealth_prepared
		var was_hidden := ninja.stealth_active

		ninja.finish_move()

		if was_prepared:

			board.add_log("Ninja entra en Sigilo.")

		elif was_hidden:

			board.add_log("Ninja sale del Sigilo.")

	# =====================================
	# Paladín
	# =====================================

	if selected_character is Paladin:

		var paladin := selected_character as Paladin

		paladin.finish_move()

	# =====================================
	# Sumo
	# =====================================

	if selected_character is Sumo:

		var sumo := selected_character as Sumo

		sumo.finish_move()

	message_manager.check_scroll(
		selected_character
	)

	check_victory(
		selected_character
	)

	if game_over:
		return

	check_defeat()

	if game_over:
		return

	turn_manager.register_action(
		selected_character
	)

	deselect()

	update_hud()


func check_victory(character: Character):

	if !character.is_carrier():
		return

	if character.current_cell.x != BoardState.ROWS - 1:
		return

	game_over = true

	deselect()

	board.add_log("¡Victoria!")

	log_manager.disable()


func has_living_carrier() -> bool:

	for character in characters:

		if !character.alive:
			continue

		if character.is_carrier():

			return true

	return false


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

	# Derrota si todos los personajes han muerto.
	if characters.is_empty():

		game_over = true

		deselect()

		board.add_log("¡Derrota!")

		log_manager.disable()

		return

	# Si el pergamino aún está en el tablero,
	# todavía es posible ganar.
	if scroll.visible:
		return

	# El pergamino ya fue recogido.
	# Si no queda ningún portador vivo,
	# la partida está perdida.
	if !has_living_carrier():

		game_over = true

		deselect()

		board.add_log("¡Derrota!")

		log_manager.disable()


func _on_end_turn_pressed():

	if game_over:
		return

	deselect()

	enemy_manager.enemy_turn()

	# La partida pudo terminar durante
	# el turno enemigo.
	if game_over:
		return

	turn_manager.end_turn()

	update_hud()
