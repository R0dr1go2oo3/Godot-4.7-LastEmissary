extends Node

class_name EnemyManager


const ORTHOGONAL_TURRETS := 10
const DIAGONAL_TURRETS := 10

const ORTHOGONAL_WARRIORS := 5
const DIAGONAL_WARRIORS := 5

const BOSSES := 2


var board: BoardState
var enemy_container: Node2D

var enemies: Array[Enemy] = []

var torreta_ortogonal_scene: PackedScene
var torreta_diagonal_scene: PackedScene
var guerrero_ortogonal_scene: PackedScene
var guerrero_diagonal_scene: PackedScene
var jefe_scene: PackedScene


# =====================================
# SETUP
# =====================================

func setup(
	board_state: BoardState,
	container: Node2D,
	torreta_ortogonal: PackedScene,
	torreta_diagonal: PackedScene,
	guerrero_ortogonal: PackedScene,
	guerrero_diagonal: PackedScene,
	jefe: PackedScene
):

	board = board_state
	enemy_container = container

	torreta_ortogonal_scene = torreta_ortogonal
	torreta_diagonal_scene = torreta_diagonal
	guerrero_ortogonal_scene = guerrero_ortogonal
	guerrero_diagonal_scene = guerrero_diagonal
	jefe_scene = jefe


# =====================================
# GENERACIÓN
# =====================================

func generate_enemies():

	clear_enemies()

	spawn_orthogonal_turrets()
	spawn_diagonal_turrets()

	spawn_orthogonal_warriors()
	spawn_diagonal_warriors()

	generate_boss()


func spawn_orthogonal_turrets() -> void:

	for i in ORTHOGONAL_TURRETS:

		spawn_orthogonal_turret(
			board.get_random_free_cell(3, 23)
		)


func spawn_diagonal_turrets() -> void:

	for i in DIAGONAL_TURRETS:

		spawn_diagonal_turret(
			board.get_random_free_cell(3, 23)
		)


func spawn_orthogonal_warriors() -> void:

	for i in ORTHOGONAL_WARRIORS:

		spawn_orthogonal_warrior(
			board.get_random_free_cell(9, 23)
		)


func spawn_diagonal_warriors() -> void:

	for i in DIAGONAL_WARRIORS:

		spawn_diagonal_warrior(
			board.get_random_free_cell(9, 23)
		)


func generate_boss() -> void:

	for i in BOSSES:

		spawn_boss(
			board.get_random_free_cell(19, 24)
		)


# =====================================
# SPAWN
# =====================================

func spawn_orthogonal_turret(cell: Vector2i) -> Enemy:

	return spawn_enemy(
		torreta_ortogonal_scene,
		cell
	)


func spawn_diagonal_turret(cell: Vector2i) -> Enemy:

	return spawn_enemy(
		torreta_diagonal_scene,
		cell
	)


func spawn_orthogonal_warrior(cell: Vector2i) -> Enemy:

	return spawn_enemy(
		guerrero_ortogonal_scene,
		cell
	)


func spawn_diagonal_warrior(cell: Vector2i) -> Enemy:

	return spawn_enemy(
		guerrero_diagonal_scene,
		cell
	)


func spawn_boss(cell: Vector2i) -> Enemy:

	return spawn_enemy(
		jefe_scene,
		cell
	)


func spawn_enemy(
	scene: PackedScene,
	cell: Vector2i
) -> Enemy:

	var enemy := scene.instantiate() as Enemy

	enemy.name += "_" + str(enemies.size())

	enemy_container.add_child(enemy)

	enemy.setup_board(board)
	enemy.spawn(cell)

	enemies.append(enemy)

	return enemy


# =====================================
# TURNO
# =====================================

func enemy_turn():

	board.add_log("Comienza el turno enemigo.")

	var current_enemies: Array[Enemy] = enemies.duplicate()

	for enemy in current_enemies:

		if enemy == null:
			continue

		if !is_instance_valid(enemy):
			continue

		enemy.take_turn()


# =====================================
# CONSULTAS
# =====================================

func get_enemies() -> Array[Enemy]:

	return enemies


func get_enemy_count() -> int:

	return enemies.size()


func get_enemy_at(cell: Vector2i) -> Enemy:

	for enemy in enemies:

		if enemy.current_cell == cell:
			return enemy

	return null


func has_enemy(cell: Vector2i) -> bool:

	return get_enemy_at(cell) != null


# =====================================
# GESTIÓN
# =====================================

func add_enemy(enemy: Enemy):

	if enemy in enemies:
		return

	enemies.append(enemy)


func remove_enemy(enemy: Enemy):

	if enemy == null:
		return

	enemies.erase(enemy)

	if is_instance_valid(enemy):

		enemy.queue_free()


func clear_enemies():

	for enemy in enemies:

		if enemy != null and is_instance_valid(enemy):

			enemy.queue_free()

	enemies.clear()
