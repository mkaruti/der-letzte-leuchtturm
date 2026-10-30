class_name IslandGate
extends StaticBody2D
## Wiederverwendbares Tor mit eigener Darstellung und Kollision.
## Position und Größe entsprechen dem bestehenden Insel-Prototyp.

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var is_open: bool = false


func open_gate() -> void:
	if is_open:
		return
	is_open = true
	# Sicher auch dann, wenn das Tor später während eines Physikschritts öffnet.
	collision_shape.set_deferred("disabled", true)
	queue_redraw()


func _draw() -> void:
	if is_open:
		return
	# Die ursprünglichen Koordinaten relativ zur Tor-Mitte (1024, 640).
	draw_rect(Rect2(-13, -60, 26, 120), Color("#b6573b"))
	draw_rect(Rect2(-7, -55, 14, 110), Color("#e08d58"))
