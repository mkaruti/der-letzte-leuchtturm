class_name ForestRuneStone
extends Node2D
## Ein wiederverwendbarer Runenstein des ersten Waldrätsels.
## Der Stein hat absichtlich keine Kollision: Lio kann bequem herantreten.

@export_enum("Sonne", "Blatt", "Mond") var kind: int = 0

var is_lit: bool = false


func set_lit(value: bool) -> void:
	if is_lit == value:
		return
	is_lit = value
	queue_redraw()


func get_rune_name() -> String:
	match kind:
		0:
			return "Sonnenrune"
		1:
			return "Blattrune"
		2:
			return "Mondrune"
	return "Rune"


func _draw() -> void:
	# Kleiner, selbst gezeichneter Pixel-Art-Stein; kein neues Bild-Asset nötig.
	var rim := Color("#c8cba1") if is_lit else Color("#344b40")
	var face := Color("#7f957b") if is_lit else Color("#586c61")
	var rune_color := Color("#e4d888")
	match kind:
		0:
			rune_color = Color("#f7c66d")
		1:
			rune_color = Color("#a2e093")
		2:
			rune_color = Color("#c4ceff")
	if not is_lit:
		rune_color = rune_color.darkened(0.30)

	draw_rect(Rect2(-28, -19, 56, 49), Color("#21372f"))
	draw_rect(Rect2(-25, -25, 50, 46), rim)
	draw_rect(Rect2(-20, -21, 40, 38), face)
	draw_rect(Rect2(-20, 16, 40, 5), Color("#425b4a"))

	match kind:
		0:
			# Sonne: Quadrat und pixelige Strahlen.
			draw_rect(Rect2(-7, -12, 14, 14), rune_color)
			draw_rect(Rect2(-3, -20, 6, 6), rune_color)
			draw_rect(Rect2(-3, 4, 6, 6), rune_color)
			draw_rect(Rect2(-16, -8, 7, 6), rune_color)
			draw_rect(Rect2(9, -8, 7, 6), rune_color)
		1:
			# Blatt: symmetrische Blattform und Stängel.
			draw_rect(Rect2(-6, -16, 12, 20), rune_color)
			draw_rect(Rect2(-11, -11, 22, 10), rune_color)
			draw_rect(Rect2(-2, 4, 4, 7), rune_color)
		2:
			# Mond: Mondsichel aus versetzten Quadraten.
			draw_rect(Rect2(-11, -15, 17, 22), rune_color)
			draw_rect(Rect2(-6, -19, 11, 6), rune_color)
			draw_rect(Rect2(-6, 6, 11, 5), rune_color)
			draw_rect(Rect2(-4, -15, 13, 16), face)

	if is_lit:
		draw_rect(Rect2(-19, 25, 38, 3), rune_color)
