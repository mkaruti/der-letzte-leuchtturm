extends Node2D
## Insel mit Schalter, Wald- und Höhlenzugang sowie Leuchtturm.
## Der alte Testkristall ist entfernt. Erst drei echte Dungeon-Kristalle
## bringen den Leuchtturm zum Leuchten.

const SWITCH_POS = Vector2(530, 370)
const LIGHTHOUSE_POS = Vector2(1790, 640)
const INTERACTION_RADIUS = 72.0
# Erster Waldeingang auf der Westseite der Insel. Keine vorhandenen Bäume versetzen.
const FOREST_ENTRANCE_POS = Vector2(650, 640)
const FOREST_SCENE_PATH = "res://scenes/forest.tscn"
# Höhleneingang östlich des Tores, mit freier Fläche vor dem Portal.
const CAVE_ENTRANCE_POS: Vector2 = Vector2(1430, 780)
const CAVE_SCENE_PATH: String = "res://scenes/cave.tscn"
# Erster echter Dungeon-Kristall: Wald.
const FOREST_CRYSTAL_ID: StringName = &"forest"
# Statische Inselgrafiken: Schalter und Leuchtturm.
const SWITCH_OFF = preload("res://assets/switch_off.png")
const SWITCH_ON = preload("res://assets/switch_on.png")
const LIGHTHOUSE_OFF = preload("res://assets/lighthouse_unlit.png")
const LIGHTHOUSE_ON = preload("res://assets/lighthouse_lit.png")

@onready var player: CharacterBody2D = $Player
@onready var game_ui: GameUI = $UI
@onready var gate: IslandGate = $Gate

func _ready() -> void:
	# Außengrenzen der größeren Insel (Weltmaß 2048 x 1280 Pixel).
	_create_wall(Vector2(1024, 8), Vector2(2048, 16))
	_create_wall(Vector2(1024, 1272), Vector2(2048, 16))
	_create_wall(Vector2(8, 640), Vector2(16, 1280))
	_create_wall(Vector2(2040, 640), Vector2(16, 1280))

	# Durchgang in der Mitte. Alle Interaktionen bleiben wie vorher.
	_create_wall(Vector2(1024, 298), Vector2(26, 564))
	_create_wall(Vector2(1024, 982), Vector2(26, 564))
	# Das Tor ist jetzt eine eigene Szene ($Gate).
	# Der Rückweg aus Wald und Höhle stellt Position und offenen Torzustand wieder her.
	if GameState.returning_from_forest or GameState.returning_from_cave:
		player.global_position = GameState.island_return_position
		if GameState.island_gate_open:
			gate.open_gate()
		GameState.returning_from_forest = false
		GameState.returning_from_cave = false
	_update_objective()
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo:
			if event.keycode == KEY_E or event.physical_keycode == KEY_E:
				_interact()

func _process(_delta: float) -> void:
	if _is_near(FOREST_ENTRANCE_POS):
		game_ui.show_forest_entrance_hint()
		return
	if _is_near(CAVE_ENTRANCE_POS):
		game_ui.show_cave_entrance_hint()
		return

	if _is_near(LIGHTHOUSE_POS):
		if GameState.are_all_dungeon_crystals_delivered():
			game_ui.show_completion_message()
			return
		if _has_undelivered_forest_crystal():
			game_ui.show_forest_crystal_delivery_hint()
			return
		if GameState.is_crystal_delivered(FOREST_CRYSTAL_ID):
			game_ui.show_forest_crystal_delivered_hint(GameState.get_delivered_dungeon_crystal_count())
			return

	if not gate.is_open and _is_near(SWITCH_POS):
		game_ui.show_switch_hint()
	elif _has_undelivered_forest_crystal():
		game_ui.show_forest_crystal_carry_hint()
	else:
		game_ui.show_default_hint()

func _interact() -> void:
	if _is_near(FOREST_ENTRANCE_POS):
		GameState.begin_forest_visit(FOREST_ENTRANCE_POS + Vector2(0, 96), gate.is_open)
		var result := get_tree().change_scene_to_file(FOREST_SCENE_PATH)
		if result != OK:
			push_error("Wald-Dungeon konnte nicht geöffnet werden (Fehler %s)." % result)
		return

	if _is_near(CAVE_ENTRANCE_POS):
		GameState.begin_cave_visit(CAVE_ENTRANCE_POS + Vector2(0, 98), gate.is_open)
		var result := get_tree().change_scene_to_file(CAVE_SCENE_PATH)
		if result != OK:
			push_error("Höhlen-Dungeon konnte nicht geöffnet werden (Fehler %s)." % result)
		return

	if not gate.is_open and _is_near(SWITCH_POS):
		gate.open_gate()
		_update_objective()
		queue_redraw()
		return

	# Nur ein echter Dungeon-Kristall kann hier abgegeben werden.
	if _has_undelivered_forest_crystal() and _is_near(LIGHTHOUSE_POS):
		if GameState.deliver_crystal(FOREST_CRYSTAL_ID):
			_update_objective()
			queue_redraw()

func _is_near(point: Vector2) -> bool:
	return player.global_position.distance_to(point) <= INTERACTION_RADIUS

func _has_undelivered_forest_crystal() -> bool:
	return GameState.has_crystal(FOREST_CRYSTAL_ID) and not GameState.is_crystal_delivered(FOREST_CRYSTAL_ID)

func _update_objective() -> void:
	game_ui.update_objective(
		gate.is_open,
		GameState.has_crystal(FOREST_CRYSTAL_ID),
		GameState.is_crystal_delivered(FOREST_CRYSTAL_ID),
		GameState.get_delivered_dungeon_crystal_count()
	)

func _create_wall(center: Vector2, size: Vector2) -> StaticBody2D:
	var wall := StaticBody2D.new()
	wall.position = center
	wall.collision_layer = 1
	wall.collision_mask = 1
	var collider := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = size
	collider.shape = rectangle
	wall.add_child(collider)
	add_child(wall)
	return wall

func _draw() -> void:
	# Inselboden und Bäume bleiben in der editierbaren TileMapLayer-Szene.
	# Die Kamera folgt der Spielfigur in scenes/main.tscn.

	# Trennwand mit interaktivem Tor (Kollisionen bleiben im vorhandenen Code).
	draw_rect(Rect2(1011, 16, 26, 564), Color("#304957"))
	draw_rect(Rect2(1011, 700, 26, 564), Color("#304957"))
	# Das Tor zeichnet sich selbst (scenes/island_gate.tscn).

	draw_texture(SWITCH_ON if gate.is_open else SWITCH_OFF, SWITCH_POS - Vector2(24, 24))

	# Waldeingang: gruener Steinbogen mit einem warmen Lichtpunkt.
	draw_rect(Rect2(FOREST_ENTRANCE_POS - Vector2(40, 35), Vector2(80, 70)), Color("#163f2e"))
	draw_rect(Rect2(FOREST_ENTRANCE_POS - Vector2(31, 26), Vector2(62, 52)), Color("#35754c"))
	draw_rect(Rect2(FOREST_ENTRANCE_POS - Vector2(21, 15), Vector2(42, 40)), Color("#1b382a"))
	draw_circle(FOREST_ENTRANCE_POS + Vector2(0, -9), 7.0, Color("#c6e898"))

	# Höhleneingang: dunkler Felsbogen mit bläulich schimmerndem Inneren.
	draw_rect(Rect2(CAVE_ENTRANCE_POS - Vector2(45, 39), Vector2(90, 79)), Color("#222e40"))
	draw_rect(Rect2(CAVE_ENTRANCE_POS - Vector2(36, 31), Vector2(72, 63)), Color("#708098"))
	draw_rect(Rect2(CAVE_ENTRANCE_POS - Vector2(27, 22), Vector2(54, 55)), Color("#192436"))
	draw_rect(Rect2(CAVE_ENTRANCE_POS + Vector2(-18, 3), Vector2(36, 6)), Color("#2f5670"))
	draw_circle(CAVE_ENTRANCE_POS + Vector2(0, -13), 6.0, Color("#91c9d7"))

	draw_texture(LIGHTHOUSE_ON if GameState.are_all_dungeon_crystals_delivered() else LIGHTHOUSE_OFF, LIGHTHOUSE_POS - Vector2(64, 64))
