class_name GameUI
extends CanvasLayer
## Spielziel und Interaktionshinweise der Insel.
## Der Leuchtturm leuchtet erst bei drei echten abgegebenen Kristallen.

@onready var objective_label: Label = $Objective
@onready var message_label: Label = $Message


func update_objective(
	gate_is_open: bool,
	forest_crystal_collected: bool,
	forest_crystal_delivered: bool,
	delivered_dungeon_crystals: int
) -> void:
	var goal_text: String
	if delivered_dungeon_crystals == 3:
		goal_text = "Ziel erreicht: Der Leuchtturm leuchtet!"
	elif forest_crystal_delivered:
		goal_text = "Wald abgeschlossen! Zwei Kristalle fehlen noch."
	elif forest_crystal_collected and not gate_is_open:
		goal_text = "Ziel: Schalter aktivieren und Waldkristall abgeben"
	elif forest_crystal_collected:
		goal_text = "Ziel: Waldkristall zum Leuchtturm bringen"
	else:
		goal_text = "Ziel: Wald erkunden und Waldkristall finden"
	objective_label.text = "%s  |  Kristalle: %d/3" % [goal_text, delivered_dungeon_crystals]


func show_switch_hint() -> void:
	message_label.text = "E drücken: Schalter aktivieren und Tor öffnen"


func show_forest_crystal_delivery_hint() -> void:
	message_label.text = "E drücken: Waldkristall im Leuchtturm einsetzen"


func show_forest_crystal_delivered_hint(delivered_count: int) -> void:
	message_label.text = "Waldkristall eingesetzt! Echte Kristalle: %d/3" % delivered_count


func show_forest_crystal_carry_hint() -> void:
	message_label.text = "Waldkristall im Gepäck. Bringe ihn zum Leuchtturm im Osten!"


func show_completion_message() -> void:
	message_label.text = "Alle drei Dungeon-Kristalle eingesetzt! Der Leuchtturm leuchtet."


func show_forest_entrance_hint() -> void:
	message_label.text = "E drücken: Den Wald betreten"


func show_default_hint() -> void:
	message_label.text = "WASD / Pfeiltasten: bewegen    |    E: interagieren"


func show_cave_entrance_hint() -> void:
	message_label.text = "E drücken: Die Höhle betreten"
