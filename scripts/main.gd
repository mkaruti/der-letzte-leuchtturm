extends Node2D
## KLEINER TECHNISCHER TEST: Schalter -> Tor -> Kristall -> Leuchtturm.
## Keine externen Assets, kein fertiges Spiel. Ziel ist ein funktionierender Kernablauf.

const SWITCH_POS = Vector2(340, 205)
const CRYSTAL_POS = Vector2(867, 320)
const LIGHTHOUSE_POS = Vector2(1030, 320)
const INTERACTION_RADIUS = 72.0
# Schritt 4: erste Pixel-Art-Visualisierung. Die Mechanik bleibt unverändert.
const ISLAND_BACKGROUND = preload("res://assets/island_background.png")
const SWITCH_OFF = preload("res://assets/switch_off.png")
const SWITCH_ON = preload("res://assets/switch_on.png")
const CRYSTAL_SPRITE = preload("res://assets/crystal.png")
const LIGHTHOUSE_OFF = preload("res://assets/lighthouse_unlit.png")
const LIGHTHOUSE_ON = preload("res://assets/lighthouse_lit.png")

@onready var player: CharacterBody2D = $Player
@onready var objective_label: Label = $UI/Objective
@onready var message_label: Label = $UI/Message

var gate_body: StaticBody2D
var gate_open := false
var crystal_collected := false
var level_completed := false

func _ready() -> void:
	# Begrenzung der Szene
	_create_wall(Vector2(576, 9), Vector2(1130, 18))
	_create_wall(Vector2(576, 639), Vector2(1130, 18))
	_create_wall(Vector2(9, 324), Vector2(18, 630))
	_create_wall(Vector2(1143, 324), Vector2(18, 630))

	# Trennwand und Durchgang; Schalter öffnet das Tor im Durchgang.
	_create_wall(Vector2(610, 145), Vector2(26, 270))
	_create_wall(Vector2(610, 509), Vector2(26, 260))
	gate_body = _create_wall(Vector2(610, 325), Vector2(26, 110))
	_update_objective()
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo:
			if event.keycode == KEY_E or event.physical_keycode == KEY_E:
				_interact()

func _process(_delta: float) -> void:
	if level_completed:
		message_label.text = "Test geschafft! Schalter, Tor, Kristall und Leuchtturm funktionieren."
		return

	if not gate_open and _is_near(SWITCH_POS):
		message_label.text = "E drücken: Schalter aktivieren"
	elif gate_open and not crystal_collected and _is_near(CRYSTAL_POS):
		message_label.text = "E drücken: Kristall einsammeln"
	elif crystal_collected and _is_near(LIGHTHOUSE_POS):
		message_label.text = "E drücken: Kristall im Leuchtturm einsetzen"
	else:
		message_label.text = "WASD / Pfeiltasten: bewegen    |    E: interagieren"

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
	if level_completed:
		objective_label.text = "Ziel erreicht: der Leuchtturm leuchtet!"
	elif crystal_collected:
		objective_label.text = "Ziel: Kristall zum Leuchtturm bringen"
	elif gate_open:
		objective_label.text = "Ziel: Kristall hinter dem Tor einsammeln"
	else:
		objective_label.text = "Ziel: Schalter im Westen finden und Tor öffnen"

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
	# Phase 1: Eine bewusst einfache statische Inselgrafik. Später ersetzen
	# wir sie durch echte editierbare TileMapLayer und separate Objekt-Szenen.
	draw_texture(ISLAND_BACKGROUND, Vector2.ZERO)

	# Trennwand mit interaktivem Tor (Kollisionen bleiben im vorhandenen Code).
	draw_rect(Rect2(597, 10, 26, 270), Color("#304957"))
	draw_rect(Rect2(597, 379, 26, 260), Color("#304957"))
	if not gate_open:
		draw_rect(Rect2(597, 270, 26, 110), Color("#b6573b"))
		draw_rect(Rect2(603, 275, 14, 100), Color("#e08d58"))

	draw_texture(SWITCH_ON if gate_open else SWITCH_OFF, SWITCH_POS - Vector2(24, 24))

	if not crystal_collected:
		draw_texture(CRYSTAL_SPRITE, CRYSTAL_POS - Vector2(24, 24))

	draw_texture(LIGHTHOUSE_ON if level_completed else LIGHTHOUSE_OFF, LIGHTHOUSE_POS - Vector2(64, 64))
