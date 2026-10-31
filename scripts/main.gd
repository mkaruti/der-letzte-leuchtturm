extends Node2D
## Schritt 6: Erkunder-Insel mit Kamera. Gleicher Interaktionsablauf wie der getestete Prototyp.
## Spielwelt: 2048 x 1280 Pixel. Dieser Code steuert weiterhin den Testablauf.

const SWITCH_POS = Vector2(530, 370)
const LIGHTHOUSE_POS = Vector2(1790, 640)
const INTERACTION_RADIUS = 72.0
# Erster Waldeingang auf der Westseite der Insel. Keine vorhandenen Bäume versetzen.
const FOREST_ENTRANCE_POS = Vector2(650, 640)
const FOREST_SCENE_PATH = "res://scenes/forest.tscn"
# Der bisherige Insel-Kristall bleibt ein technischer Prototyp.
const PROTOTYPE_CRYSTAL_ID: StringName = &"prototype"
# Schritt 4: erste Pixel-Art-Visualisierung. Die Mechanik bleibt unverändert.
const SWITCH_OFF = preload("res://assets/switch_off.png")
const SWITCH_ON = preload("res://assets/switch_on.png")
const LIGHTHOUSE_OFF = preload("res://assets/lighthouse_unlit.png")
const LIGHTHOUSE_ON = preload("res://assets/lighthouse_lit.png")

@onready var player: CharacterBody2D = $Player
@onready var game_ui: GameUI = $UI
@onready var gate: IslandGate = $Gate
@onready var crystal: CollectibleCrystal = $Crystal

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
	# Nach dem Waldbesuch denselben Spielfortschritt und Torzustand wiederherstellen.
	if GameState.returning_from_forest:
		player.global_position = GameState.island_return_position
		if GameState.island_gate_open:
			gate.open_gate()
		GameState.returning_from_forest = false
	# Beim Rueckweg aus einem Dungeon bleibt ein eingesammelter Kristall weg.
	if GameState.has_crystal(PROTOTYPE_CRYSTAL_ID):
		crystal.collect()
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
	if GameState.is_crystal_delivered(PROTOTYPE_CRYSTAL_ID):
		game_ui.show_completion_message()
		return

	game_ui.update_interaction_hint(
		gate.is_open,
		crystal.is_collected,
		_is_near(SWITCH_POS),
		_is_near(crystal.global_position),
		_is_near(LIGHTHOUSE_POS)
	)

func _interact() -> void:
	if _is_near(FOREST_ENTRANCE_POS):
		GameState.begin_forest_visit(FOREST_ENTRANCE_POS + Vector2(0, 96), gate.is_open)
		var result := get_tree().change_scene_to_file(FOREST_SCENE_PATH)
		if result != OK:
			push_error("Wald-Dungeon konnte nicht geöffnet werden (Fehler %s)." % result)
		return
	if not gate.is_open and _is_near(SWITCH_POS):
		gate.open_gate()
		_update_objective()
		queue_redraw()
		return

	if gate.is_open and not crystal.is_collected and _is_near(crystal.global_position):
		if GameState.collect_crystal(PROTOTYPE_CRYSTAL_ID):
			crystal.collect()
			_update_objective()
		return

	if crystal.is_collected and not GameState.is_crystal_delivered(PROTOTYPE_CRYSTAL_ID) and _is_near(LIGHTHOUSE_POS):
		if GameState.deliver_crystal(PROTOTYPE_CRYSTAL_ID):
			_update_objective()
			queue_redraw()

func _is_near(point: Vector2) -> bool:
	return player.global_position.distance_to(point) <= INTERACTION_RADIUS

func _update_objective() -> void:
	game_ui.update_objective(gate.is_open, crystal.is_collected, GameState.is_crystal_delivered(PROTOTYPE_CRYSTAL_ID))

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
	# Kristall-Sprite und Einsammelzustand liegen jetzt in $Crystal.

	draw_texture(LIGHTHOUSE_ON if GameState.is_crystal_delivered(PROTOTYPE_CRYSTAL_ID) else LIGHTHOUSE_OFF, LIGHTHOUSE_POS - Vector2(64, 64))
