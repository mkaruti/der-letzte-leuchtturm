class_name CavePushBlock
extends AnimatableBody2D
## Steinblock für das Höhlen-Druckplattenrätsel. Position steuert cave.gd.

var is_activated: bool = false


func set_activated(value: bool) -> void:
	is_activated = value
	queue_redraw()


func _draw() -> void:
	# Grober, quadratischer Stein mit eingeritztem Symbol.
	var rim := Color("#d5e5b8") if is_activated else Color("#8493a7")
	var face := Color("#9cbea2") if is_activated else Color("#596b80")
	draw_rect(Rect2(-27, -25, 54, 54), Color("#202838"))
	draw_rect(Rect2(-23, -27, 46, 50), rim)
	draw_rect(Rect2(-18, -22, 36, 40), face)
	draw_rect(Rect2(-15, -20, 30, 5), Color("#cfe4d7") if is_activated else Color("#9cacc0"))
	draw_rect(Rect2(-4, -13, 8, 24), Color("#e9f7bd") if is_activated else Color("#acb9c9"))
	draw_rect(Rect2(-13, -5, 26, 8), Color("#e9f7bd") if is_activated else Color("#acb9c9"))
