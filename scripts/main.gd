extends Node2D
## Schritt 6: Erkunder-Insel mit Kamera. Gleicher Interaktionsablauf wie der getestete Prototyp.
## Spielwelt: 2048 x 1280 Pixel. Dieser Code steuert weiterhin den Testablauf.

const SWITCH_POS = Vector2(530, 370)
const CRYSTAL_POS = Vector2(1460, 640)
const LIGHTHOUSE_POS = Vector2(1790, 640)
const INTERACTION_RADIUS = 72.0
# Schritt 4: erste Pixel-Art-Visualisierung. Die Mechanik bleibt unverändert.
const SWITCH_OFF = preload("res://assets/switch_off.png")
const SWITCH_ON = preload("res://assets/switch_on.png")
const CRYSTAL_SPRITE = preload("res://assets/crystal.png")
const LIGHTHOUSE_OFF = preload("res://assets/lighthouse_unlit.png")
const LIGHTHOUSE_ON = preload("res://assets/lighthouse_lit.png")

@onready var player: CharacterBody2D = $Player
@onready var game_ui: GameUI = $UI

var gate_body: StaticBody2D
var gate_open := false
var crystal_collected := false
var level_completed := false

func _ready() -> void:
	# Außengrenzen der größeren Insel (Weltmaß 2048 x 1280 Pixel).
	_create_wall(Vector2(1024, 8), Vector2(2048, 16))
	_create_wall(Vector2(1024, 1272), Vector2(2048, 16))
	_create_wall(Vector2(8, 640), Vector2(16, 1280))
	_create_wall(Vector2(2040, 640), Vector2(16, 1280))

	# Durchgang in der Mitte. Alle Interaktionen bleiben wie vorher.
	_create_wall(Vector2(1024, 298), Vector2(26, 564))
	_create_wall(Vector2(1024, 982), Vector2(26, 564))
	gate_body = _create_wall(Vector2(1024, 640), Vector2(26, 120))
	_update_objective()
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo:
			if event.keycode == KEY_E or event.physical_keycode == KEY_E:
				_interact()

func _process(_delta: float) -> void:
	if level_completed:
		game_ui.show_completion_message()
		return

	game_ui.update_interaction_hint(
		gate_open,
		crystal_collected,
		_is_near(SWITCH_POS),
		_is_near(CRYSTAL_POS),
		_is_near(LIGHTHOUSE_POS)
	)

func _interact() -> void:
	if not gate_open and _is_near(SWITCH_POS):
		gate_open = true
		gate_body.queue_free()
		_update_objective()
		queue_redraw()
		return

	if gate_open and not crystal_collected and _is_near(CRYSTAL_POS):
		crystal_collected = true
		_update_objective()
		queue_redraw()
		return

	if crystal_collected and not level_completed and _is_near(LIGHTHOUSE_POS):
		level_completed = true
		_update_objective()
		queue_redraw()

func _is_near(point: Vector2) -> bool:
	return player.global_position.distance_to(point) <= INTERACTION_RADIUS

func _update_objective() -> void:
	game_ui.update_objective(gate_open, crystal_collected, level_completed)

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
	if not gate_open:
		draw_rect(Rect2(1011, 580, 26, 120), Color("#b6573b"))
		draw_rect(Rect2(1017, 585, 14, 110), Color("#e08d58"))

	draw_texture(SWITCH_ON if gate_open else SWITCH_OFF, SWITCH_POS - Vector2(24, 24))

	if not crystal_collected:
		draw_texture(CRYSTAL_SPRITE, CRYSTAL_POS - Vector2(24, 24))

	draw_texture(LIGHTHOUSE_ON if level_completed else LIGHTHOUSE_OFF, LIGHTHOUSE_POS - Vector2(64, 64))
