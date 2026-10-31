extends Node2D
## Schritt 12: Wald-Dungeon – erste begehbare Szene mit Rueckweg zur Insel.
## Noch kein Raetsel und kein Dungeon-Kristall: beides folgt separat.

const WORLD_SIZE: Vector2 = Vector2(1280, 800)
const EXIT_POS: Vector2 = Vector2(640, 735)
const EXIT_RADIUS: float = 76.0
const ISLAND_SCENE_PATH: String = "res://scenes/main.tscn"

@onready var player: CharacterBody2D = $Player
@onready var message_label: Label = $UI/Message


func _ready() -> void:
	# Zusaetzliche unsichtbare Weltgrenzen, unabhaengig vom Terrain-Atlas.
	_create_boundary(Vector2(640, 8), Vector2(1280, 16))
	_create_boundary(Vector2(640, 792), Vector2(1280, 16))
	_create_boundary(Vector2(8, 400), Vector2(16, 800))
	_create_boundary(Vector2(1272, 400), Vector2(16, 800))
	queue_redraw()


func _process(_delta: float) -> void:
	if player.global_position.distance_to(EXIT_POS) <= EXIT_RADIUS:
		message_label.text = "E drücken: Zur Insel zurückkehren"
	else:
		message_label.text = "WASD / Pfeiltasten: bewegen  |  Ausgang im Süden"


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E or event.physical_keycode == KEY_E:
			if player.global_position.distance_to(EXIT_POS) <= EXIT_RADIUS:
				GameState.finish_forest_visit()
				var result := get_tree().change_scene_to_file(ISLAND_SCENE_PATH)
				if result != OK:
					GameState.returning_from_forest = false
					push_error("Insel konnte nicht geladen werden (Fehler %s)." % result)


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
	# Eingang/Exit bei der unteren Waldlichtung, deutlich sichtbar.
	draw_rect(Rect2(EXIT_POS - Vector2(48, 27), Vector2(96, 54)), Color("#173d30"))
	draw_rect(Rect2(EXIT_POS - Vector2(37, 21), Vector2(74, 41)), Color("#6a9862"))
	draw_rect(Rect2(EXIT_POS - Vector2(27, 10), Vector2(54, 30)), Color("#263c32"))
	draw_circle(EXIT_POS + Vector2(0, -14), 6.0, Color("#f4e1a0"))

	# Alter Steinkreis als Landmarke fuer das spaetere Waldraetsel.
	var altar_center := Vector2(640, 200)
	draw_circle(altar_center, 73.0, Color("#244c3c"))
	draw_circle(altar_center, 56.0, Color("#62745c"))
	draw_circle(altar_center, 43.0, Color("#315c48"))
	draw_circle(altar_center, 19.0, Color("#98b19a"))
	draw_circle(altar_center, 11.0, Color("#c5d6ab"))
	for i in range(8):
		var angle := TAU * float(i) / 8.0
		var point := altar_center + Vector2(cos(angle), sin(angle)) * 67.0
		draw_rect(Rect2(point - Vector2(12, 12), Vector2(24, 24)), Color("#879988"))
