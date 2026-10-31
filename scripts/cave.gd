extends Node2D
## Schritt 16: Begehbare Höhle mit einem Rückweg zur Insel.
## Höhlenrätsel und Höhlenkristall folgen in eigenen Entwicklungsschritten.

const WORLD_SIZE: Vector2 = Vector2(1280, 800)
const EXIT_POS: Vector2 = Vector2(640, 735)
const EXIT_RADIUS: float = 75.0
const ISLAND_SCENE_PATH: String = "res://scenes/main.tscn"

# Felsformationen außerhalb des zentralen begehbaren Weges.
const ROCKS = [
	[Vector2(185, 175), 35.0],
	[Vector2(350, 250), 32.0],
	[Vector2(960, 240), 42.0],
	[Vector2(1070, 400), 37.0],
	[Vector2(285, 480), 35.0],
	[Vector2(940, 535), 36.0],
	[Vector2(180, 660), 42.0],
	[Vector2(1050, 675), 34.0],
]

@onready var player: CharacterBody2D = $Player
@onready var message_label: Label = $UI/Message


func _ready() -> void:
	# Physikalische Grenzen wie im Wald.
	_create_boundary(Vector2(640, 8), Vector2(1280, 16))
	_create_boundary(Vector2(640, 792), Vector2(1280, 16))
	_create_boundary(Vector2(8, 400), Vector2(16, 800))
	_create_boundary(Vector2(1272, 400), Vector2(16, 800))
	for rock in ROCKS:
		_create_rock_collision(rock[0], rock[1])
	queue_redraw()


func _process(_delta: float) -> void:
	if player.global_position.distance_to(EXIT_POS) <= EXIT_RADIUS:
		message_label.text = "E drücken: Zur Insel zurückkehren"
	else:
		message_label.text = "WASD / Pfeiltasten: Höhle erkunden  |  Ausgang im Süden"


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E or event.physical_keycode == KEY_E:
			if player.global_position.distance_to(EXIT_POS) <= EXIT_RADIUS:
				GameState.finish_cave_visit()
				var result := get_tree().change_scene_to_file(ISLAND_SCENE_PATH)
				if result != OK:
					GameState.returning_from_cave = false
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


func _create_rock_collision(center: Vector2, radius: float) -> void:
	var body := StaticBody2D.new()
	body.position = center
	body.collision_layer = 1
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = radius * 0.77
	shape.shape = circle
	body.add_child(shape)
	add_child(body)


func _draw() -> void:
	# Grobe Felsen aus übereinanderliegenden, kantigen Schichten.
	for rock in ROCKS:
		var center: Vector2 = rock[0]
		var r: float = rock[1]
		draw_circle(center + Vector2(3, 7), r + 8.0, Color("#202a3a"))
		draw_rect(Rect2(center - Vector2(r, r * 0.7), Vector2(2 * r, r * 1.5)), Color("#344158"))
		draw_rect(Rect2(center - Vector2(r * 0.7, r * 0.87), Vector2(1.4 * r, r * 1.05)), Color("#667589"))
		draw_rect(Rect2(center - Vector2(r * 0.4, r * 0.6), Vector2(r * 0.68, r * 0.18)), Color("#8c9aab"))

	# Kalte Felsadern als Atmosphäre (keine interaktiven Kristalle).
	for p in [Vector2(220, 325), Vector2(1110, 320), Vector2(175, 570), Vector2(1060, 155)]:
		draw_rect(Rect2(p - Vector2(12, 5), Vector2(24, 10)), Color("#314957"))
		draw_rect(Rect2(p - Vector2(3, 11), Vector2(6, 23)), Color("#82bdc2"))
		draw_rect(Rect2(p + Vector2(7, -4), Vector2(5, 9)), Color("#5b899e"))

	# Verwitterte Steintafel im Norden – Landmarke für das nächste Rätsel.
	var tablet := Vector2(640, 176)
	draw_rect(Rect2(tablet - Vector2(58, 35), Vector2(116, 76)), Color("#222c3b"))
	draw_rect(Rect2(tablet - Vector2(50, 30), Vector2(100, 60)), Color("#8290a2"))
	draw_rect(Rect2(tablet - Vector2(43, 23), Vector2(86, 46)), Color("#515f74"))
	draw_rect(Rect2(tablet + Vector2(-24, -6), Vector2(48, 7)), Color("#a0b7ba"))
	draw_rect(Rect2(tablet + Vector2(-6, -18), Vector2(12, 32)), Color("#a0b7ba"))

	# Rückweg im Süden – heller Steinbogen mit sichtbarem Durchgang.
	draw_rect(Rect2(EXIT_POS - Vector2(50, 29), Vector2(100, 58)), Color("#1b2534"))
	draw_rect(Rect2(EXIT_POS - Vector2(42, 23), Vector2(84, 47)), Color("#899bae"))
	draw_rect(Rect2(EXIT_POS - Vector2(31, 14), Vector2(62, 38)), Color("#293849"))
	draw_circle(EXIT_POS + Vector2(0, -12), 5.0, Color("#b2e3e0"))
