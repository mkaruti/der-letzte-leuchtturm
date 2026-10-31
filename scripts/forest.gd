extends Node2D
## Schritt 13: Der alte Steinkreis. Drei Runen in der Reihenfolge
## Sonne -> Blatt -> Mond aktivieren. Danach erscheint der Waldkristall.

const WORLD_SIZE: Vector2 = Vector2(1280, 800)
const EXIT_POS: Vector2 = Vector2(640, 735)
const EXIT_RADIUS: float = 76.0
const ALTAR_POS: Vector2 = Vector2(640, 200)
const ALTAR_RADIUS: float = 74.0
const RUNE_RADIUS: float = 64.0
const CRYSTAL_RADIUS: float = 70.0
const FOREST_CRYSTAL_ID: StringName = &"forest"
const ISLAND_SCENE_PATH: String = "res://scenes/main.tscn"

@onready var player: CharacterBody2D = $Player
@onready var objective_label: Label = $UI/Objective
@onready var message_label: Label = $UI/Message
@onready var sun_rune: ForestRuneStone = $Runes/Sun
@onready var leaf_rune: ForestRuneStone = $Runes/Leaf
@onready var moon_rune: ForestRuneStone = $Runes/Moon
@onready var forest_crystal: CollectibleCrystal = $ForestCrystal

var _runes: Array[ForestRuneStone] = []
var _next_rune_index: int = 0
var _feedback_text: String = ""
var _feedback_seconds: float = 0.0


func _ready() -> void:
	_runes.append(sun_rune)
	_runes.append(leaf_rune)
	_runes.append(moon_rune)

	# Bereits gelöste Rätsel bleiben auch nach einem Szenenwechsel gelöst.
	if GameState.forest_puzzle_solved:
		_next_rune_index = _runes.size()
		for rune in _runes:
			rune.set_lit(true)

	# Der Kristall wird erst nach der Lösung sichtbar und bleibt nach dem
	# Einsammeln auch bei erneutem Betreten des Waldes verschwunden.
	_refresh_forest_crystal()

	# Die bestehenden, unsichtbaren Weltgrenzen bleiben unverändert.
	_create_boundary(Vector2(640, 8), Vector2(1280, 16))
	_create_boundary(Vector2(640, 792), Vector2(1280, 16))
	_create_boundary(Vector2(8, 400), Vector2(16, 800))
	_create_boundary(Vector2(1272, 400), Vector2(16, 800))
	_update_objective()
	queue_redraw()


func _process(delta: float) -> void:
	if _feedback_seconds > 0.0:
		_feedback_seconds = maxf(0.0, _feedback_seconds - delta)
		if _feedback_seconds > 0.0:
			message_label.text = _feedback_text
			return

	if _is_near(EXIT_POS, EXIT_RADIUS):
		message_label.text = "E drücken: Zur Insel zurückkehren"
		return

	if _can_collect_forest_crystal() and _is_near(forest_crystal.global_position, CRYSTAL_RADIUS):
		message_label.text = "E drücken: Waldkristall einsammeln"
		return

	var rune_index := _nearest_rune_index()
	if rune_index >= 0:
		message_label.text = "E drücken: %s berühren" % _runes[rune_index].get_rune_name()
	elif _is_near(ALTAR_POS, ALTAR_RADIUS):
		message_label.text = "E drücken: Die Inschrift am Steinkreis lesen"
	elif GameState.forest_puzzle_solved:
		message_label.text = "Der Steinkreis leuchtet. | Ausgang im Süden"
	else:
		message_label.text = "WASD / Pfeiltasten: bewegen | Hinweis am Steinkreis"


func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if not (event.keycode == KEY_E or event.physical_keycode == KEY_E):
		return

	if _is_near(EXIT_POS, EXIT_RADIUS):
		GameState.finish_forest_visit()
		var result := get_tree().change_scene_to_file(ISLAND_SCENE_PATH)
		if result != OK:
			GameState.returning_from_forest = false
			push_error("Insel konnte nicht geladen werden (Fehler %s)." % result)
		return

	if _can_collect_forest_crystal() and _is_near(forest_crystal.global_position, CRYSTAL_RADIUS):
		if GameState.collect_crystal(FOREST_CRYSTAL_ID):
			forest_crystal.collect()
			_refresh_forest_crystal()
			_update_objective()
			_show_feedback("Waldkristall eingesammelt! Kehre zum Ausgang im Süden zurück.", 4.0)
		return

	var rune_index := _nearest_rune_index()
	if rune_index >= 0:
		_activate_rune(rune_index)
		return

	if _is_near(ALTAR_POS, ALTAR_RADIUS):
		_show_feedback("Inschrift: Erst die Sonne, dann das Blatt, zuletzt der Mond.", 5.0)


func _nearest_rune_index() -> int:
	var closest_index: int = -1
	var closest_distance: float = RUNE_RADIUS
	for index in range(_runes.size()):
		var distance: float = player.global_position.distance_to(_runes[index].global_position)
		if distance <= closest_distance:
			closest_distance = distance
			closest_index = index
	return closest_index


func _activate_rune(index: int) -> void:
	if GameState.forest_puzzle_solved:
		_show_feedback("Die drei Runen leuchten bereits. Der Steinkreis ist aktiviert!", 3.0)
		return

	if index < _next_rune_index:
		_show_feedback("Diese Rune leuchtet bereits. Suche die nächste!", 2.5)
		return

	if index != _next_rune_index:
		_next_rune_index = 0
		for rune in _runes:
			rune.set_lit(false)
		_update_objective()
		_show_feedback("Falsche Reihenfolge! Die Runen erlöschen.", 3.0)
		return

	_runes[index].set_lit(true)
	_next_rune_index += 1
	_update_objective()

	if _next_rune_index == _runes.size():
		GameState.solve_forest_puzzle()
		_refresh_forest_crystal()
		_update_objective()
		queue_redraw()
		_show_feedback("Rätsel gelöst! Der alte Steinkreis beginnt zu leuchten!", 5.0)
	else:
		_show_feedback("%s aktiviert (%d von 3)." % [_runes[index].get_rune_name(), _next_rune_index], 2.5)


func _update_objective() -> void:
	if GameState.has_crystal(FOREST_CRYSTAL_ID):
		objective_label.text = "Wald: Kristall gefunden! Kehre zur Insel zurück."
	elif GameState.forest_puzzle_solved:
		objective_label.text = "Wald: Sammle den Kristall am leuchtenden Steinkreis ein."
	else:
		objective_label.text = "Wald: Rätsel des Steinkreises lösen (%d/3 Runen)" % _next_rune_index


func _can_collect_forest_crystal() -> bool:
	return GameState.forest_puzzle_solved and not GameState.has_crystal(FOREST_CRYSTAL_ID)


func _refresh_forest_crystal() -> void:
	if GameState.has_crystal(FOREST_CRYSTAL_ID):
		forest_crystal.collect()
		forest_crystal.hide()
	else:
		forest_crystal.visible = GameState.forest_puzzle_solved


func _show_feedback(text: String, seconds: float) -> void:
	_feedback_text = text
	_feedback_seconds = seconds
	message_label.text = text


func _is_near(point: Vector2, radius: float) -> bool:
	return player.global_position.distance_to(point) <= radius


func _create_boundary(center: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = center
	body.collision_layer = 1
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = size
	shape.shape = rectangle
	body.add_child(shape)
	add_child(body)


func _draw() -> void:
	# Waldausgang wie in Schritt 12.
	draw_rect(Rect2(EXIT_POS - Vector2(48, 27), Vector2(96, 54)), Color("#173d30"))
	draw_rect(Rect2(EXIT_POS - Vector2(37, 21), Vector2(74, 41)), Color("#6a9862"))
	draw_rect(Rect2(EXIT_POS - Vector2(27, 10), Vector2(54, 30)), Color("#263c32"))
	draw_circle(EXIT_POS + Vector2(0, -14), 6.0, Color("#f4e1a0"))

	# Der bereits vorhandene Steinkreis bekommt nach Erfolg einen hellen Kern.
	var activated: bool = GameState.forest_puzzle_solved
	var ring_color := Color("#a5c891") if activated else Color("#879988")
	draw_circle(ALTAR_POS, 73.0, Color("#244c3c"))
	draw_circle(ALTAR_POS, 56.0, Color("#62745c"))
	draw_circle(ALTAR_POS, 43.0, Color("#315c48"))
	draw_circle(ALTAR_POS, 19.0, Color("#98b19a"))
	draw_circle(ALTAR_POS, 11.0, Color("#e6edac") if activated else Color("#c5d6ab"))
	if activated:
		draw_circle(ALTAR_POS, 5.0, Color("#fff7c1"))
	for i in range(8):
		var angle := TAU * float(i) / 8.0
		var point := ALTAR_POS + Vector2(cos(angle), sin(angle)) * 67.0
		draw_rect(Rect2(point - Vector2(12, 12), Vector2(24, 24)), ring_color)
