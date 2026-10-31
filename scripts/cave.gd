extends Node2D
## Schritt 17: Steinblock auf die Druckplatte schieben, um die Steintafel zu aktivieren.
## Der Höhlenkristall folgt erst im nächsten Entwicklungsschritt.

const WORLD_SIZE: Vector2 = Vector2(1280, 800)
const EXIT_POS: Vector2 = Vector2(640, 735)
const EXIT_RADIUS: float = 75.0
const TABLET_POS: Vector2 = Vector2(640, 176)
const TABLET_RADIUS: float = 88.0
const BLOCK_START_POS: Vector2 = Vector2(528, 440)
const PLATE_POS: Vector2 = Vector2(720, 440)
const BLOCK_STEP: float = 64.0
const BLOCK_INTERACT_RADIUS: float = 84.0
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
@onready var objective_label: Label = $UI/Objective
@onready var push_block: CavePushBlock = $PushBlock

var _feedback_text: String = ""
var _feedback_seconds: float = 0.0
var _push_count: int = 0


func _ready() -> void:
	# Nach erfolgreichem Rätsel steht der Block dauerhaft auf der Druckplatte.
	if GameState.cave_puzzle_solved:
		_push_count = 3
		push_block.position = PLATE_POS
		push_block.set_activated(true)
	else:
		_push_count = 0
		push_block.position = BLOCK_START_POS

	# Physikalische Grenzen wie im Wald.
	_create_boundary(Vector2(640, 8), Vector2(1280, 16))
	_create_boundary(Vector2(640, 792), Vector2(1280, 16))
	_create_boundary(Vector2(8, 400), Vector2(16, 800))
	_create_boundary(Vector2(1272, 400), Vector2(16, 800))
	for rock in ROCKS:
		_create_rock_collision(rock[0], rock[1])
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
	elif _is_near(TABLET_POS, TABLET_RADIUS):
		message_label.text = "E drücken: Steintafel untersuchen"
	elif not GameState.cave_puzzle_solved and _is_near(push_block.global_position, BLOCK_INTERACT_RADIUS):
		message_label.text = "E drücken: Stein nach rechts schieben (%d/3)" % _push_count
	elif GameState.cave_puzzle_solved:
		message_label.text = "Steintafel aktiviert! Ausgang im Süden"
	else:
		message_label.text = "Schiebe den Stein nach rechts auf die leuchtende Platte | E: interagieren"


func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if not (event.keycode == KEY_E or event.physical_keycode == KEY_E):
		return

	if _is_near(EXIT_POS, EXIT_RADIUS):
		GameState.finish_cave_visit()
		var result := get_tree().change_scene_to_file(ISLAND_SCENE_PATH)
		if result != OK:
			GameState.returning_from_cave = false
			push_error("Insel konnte nicht geladen werden (Fehler %s)." % result)
		return

	if _is_near(TABLET_POS, TABLET_RADIUS):
		if GameState.cave_puzzle_solved:
			_show_feedback("Steintafel aktiviert! Der nächste Höhlenabschnitt wird später ergänzt.", 4.0)
		else:
			_show_feedback("Inschrift: Nur der schwere Stein kann die Druckplatte im Osten auslösen.", 5.0)
		return

	if not GameState.cave_puzzle_solved and _is_near(push_block.global_position, BLOCK_INTERACT_RADIUS):
		_push_block_to_plate()


func _push_block_to_plate() -> void:
	# Lio muss links vom Stein stehen, um ihn nach Osten zu schieben.
	var distance_y: float = absf(player.global_position.y - push_block.global_position.y)
	var distance_x: float = push_block.global_position.x - player.global_position.x
	if distance_y > 48.0 or distance_x < 35.0 or distance_x > BLOCK_INTERACT_RADIUS:
		_show_feedback("Stelle dich links neben den Stein und drücke E.", 3.0)
		return

	# Jeder erfolgreiche Tastendruck zählt als genau ein Schub.
	# Lio rückt gemeinsam mit dem Block nach rechts: So verliert er
	# nach dem ersten/zweiten Schub nicht unbemerkt die Reichweite.
	if _push_count >= 3:
		return
	_push_count += 1
	push_block.position = BLOCK_START_POS + Vector2(float(_push_count) * BLOCK_STEP, 0.0)
	player.global_position = player.global_position + Vector2(BLOCK_STEP, 0.0)

	if _push_count == 3:
		# Beim letzten Schub trifft der Block exakt die Plattenmitte.
		push_block.position = PLATE_POS
		GameState.solve_cave_puzzle()
		push_block.set_activated(true)
		_update_objective()
		queue_redraw()
		_show_feedback("3/3 Schübe! Rätsel gelöst: Die Steintafel leuchtet!", 5.0)
	else:
		_update_objective()
		_show_feedback("Schub %d/3 geschafft! Drücke E für den nächsten Schub." % _push_count, 2.4)


func _update_objective() -> void:
	if GameState.cave_puzzle_solved:
		objective_label.text = "Höhle: Steintafel aktiviert! Der Höhlenkristall folgt im nächsten Schritt."
	else:
		objective_label.text = "Höhle: Stein auf die Druckplatte schieben (%d/3)" % _push_count


func _show_feedback(message: String, duration: float) -> void:
	_feedback_text = message
	_feedback_seconds = duration
	message_label.text = message


func _is_near(pos: Vector2, radius: float) -> bool:
	return player.global_position.distance_to(pos) <= radius


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
	# Schmale Schiebebahn mit drei Feldern; die Druckplatte rechts leuchtet.
	draw_rect(Rect2(482, 402, 282, 76), Color("#242e40"))
	draw_rect(Rect2(486, 407, 274, 66), Color("#465166"))
	draw_line(Vector2(502, 417), Vector2(743, 417), Color("#8c9aad"), 3.0)
	draw_line(Vector2(502, 462), Vector2(743, 462), Color("#8c9aad"), 3.0)
	for x in [528, 592, 656]:
		draw_rect(Rect2(x - 22, 429, 44, 22), Color("#5d687b"))

	var plate_lit: bool = GameState.cave_puzzle_solved
	draw_rect(Rect2(PLATE_POS - Vector2(35, 35), Vector2(70, 70)), Color("#1b2d3a"))
	draw_rect(Rect2(PLATE_POS - Vector2(29, 29), Vector2(58, 58)), Color("#82cbb1") if plate_lit else Color("#79959a"))
	draw_rect(Rect2(PLATE_POS - Vector2(20, 20), Vector2(40, 40)), Color("#4c977f") if plate_lit else Color("#395567"))
	draw_rect(Rect2(PLATE_POS - Vector2(8, 8), Vector2(16, 16)), Color("#e1f9bc") if plate_lit else Color("#a1bdc0"))

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

	# Die Steintafel wird erst bei gelöster Druckplatte aktiviert.
	var tablet := TABLET_POS
	var tablet_lit: bool = GameState.cave_puzzle_solved
	draw_rect(Rect2(tablet - Vector2(58, 35), Vector2(116, 76)), Color("#222c3b"))
	draw_rect(Rect2(tablet - Vector2(50, 30), Vector2(100, 60)), Color("#b1d8bd") if tablet_lit else Color("#8290a2"))
	draw_rect(Rect2(tablet - Vector2(43, 23), Vector2(86, 46)), Color("#4e937c") if tablet_lit else Color("#515f74"))
	draw_rect(Rect2(tablet + Vector2(-24, -6), Vector2(48, 7)), Color("#e0f6b2") if tablet_lit else Color("#a0b7ba"))
	draw_rect(Rect2(tablet + Vector2(-6, -18), Vector2(12, 32)), Color("#e0f6b2") if tablet_lit else Color("#a0b7ba"))

	# Rückweg im Süden – heller Steinbogen mit sichtbarem Durchgang.
	draw_rect(Rect2(EXIT_POS - Vector2(50, 29), Vector2(100, 58)), Color("#1b2534"))
	draw_rect(Rect2(EXIT_POS - Vector2(42, 23), Vector2(84, 47)), Color("#899bae"))
	draw_rect(Rect2(EXIT_POS - Vector2(31, 14), Vector2(62, 38)), Color("#293849"))
	draw_circle(EXIT_POS + Vector2(0, -12), 5.0, Color("#b2e3e0"))
