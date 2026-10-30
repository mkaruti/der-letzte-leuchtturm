extends Node2D
## KLEINER TECHNISCHER TEST: Schalter -> Tor -> Kristall -> Leuchtturm.
## Keine externen Assets, kein fertiges Spiel. Ziel ist ein funktionierender Kernablauf.

const SWITCH_POS = Vector2(340, 205)
const CRYSTAL_POS = Vector2(867, 320)
const LIGHTHOUSE_POS = Vector2(1030, 320)
const INTERACTION_RADIUS = 72.0

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
    # Farben, Kacheln und Spielfeld: Platzhalter-Blockout ohne Assets.
    draw_rect(Rect2(0, 0, 1152, 648), Color("#16465a"))
    draw_rect(Rect2(24, 24, 1104, 600), Color("#52795e"))
    draw_rect(Rect2(55, 116, 450, 415), Color("#648b65"))
    draw_rect(Rect2(690, 116, 390, 415), Color("#618263"))

    # Bodenraster
    for x in range(40, 1130, 48):
        draw_line(Vector2(x, 25), Vector2(x, 623), Color(1, 1, 1, 0.055), 1.0)
    for y in range(40, 625, 48):
        draw_line(Vector2(24, y), Vector2(1128, y), Color(1, 1, 1, 0.055), 1.0)

    # Gehwege und Trennwand
    draw_rect(Rect2(525, 275, 360, 100), Color("#9b9b79"))
    draw_rect(Rect2(597, 10, 26, 270), Color("#304957"))
    draw_rect(Rect2(597, 379, 26, 260), Color("#304957"))
    if not gate_open:
        draw_rect(Rect2(597, 270, 26, 110), Color("#d56647"))

    # Dekoration (einfache Büsche)
    for pos in [Vector2(110, 170), Vector2(205, 475), Vector2(450, 455), Vector2(760, 155), Vector2(940, 495)]:
        draw_circle(pos, 21.0, Color("#355c45"))
        draw_circle(pos + Vector2(9, -8), 14.0, Color("#4a7352"))

    # Interaktiver Schalter
    draw_circle(SWITCH_POS, 30.0, Color("#233b4e"))
    draw_circle(SWITCH_POS, 19.0, Color("#4bd7ad") if gate_open else Color("#e6b36a"))
    draw_line(SWITCH_POS + Vector2(-5, 6), SWITCH_POS + Vector2(7, -9), Color.WHITE, 4.0)

    # Kristall (nur solange er noch nicht eingesammelt wurde)
    if not crystal_collected:
        var crystal_points := PackedVector2Array([
            CRYSTAL_POS + Vector2(0, -26),
            CRYSTAL_POS + Vector2(20, 0),
            CRYSTAL_POS + Vector2(0, 26),
            CRYSTAL_POS + Vector2(-20, 0)
        ])
        draw_colored_polygon(crystal_points, Color("#6af0ec"))
        draw_polyline(PackedVector2Array([
            crystal_points[0], crystal_points[1], crystal_points[2], crystal_points[3], crystal_points[0]
        ]), Color("#ddffff"), 3.0)

    # Leuchtturm: wird nach Kristall-Abgabe hell
    draw_circle(LIGHTHOUSE_POS, 47.0, Color("#2c4a58"))
    draw_circle(LIGHTHOUSE_POS, 34.0, Color("#e4e5db"))
    draw_circle(LIGHTHOUSE_POS, 17.0, Color("#ffe58c") if level_completed else Color("#4c5868"))
    if level_completed:
        draw_arc(LIGHTHOUSE_POS, 68.0, 0.0, TAU, 64, Color("#fff3ad"), 6.0)
