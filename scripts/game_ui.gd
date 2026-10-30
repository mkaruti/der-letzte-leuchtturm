class_name GameUI
extends CanvasLayer
## Darstellung von Spielziel und Interaktionshinweisen.
## Die eigentlichen Spielzustände bleiben im Main-Skript.

@onready var objective_label: Label = $Objective
@onready var message_label: Label = $Message


func update_objective(gate_is_open: bool, crystal_is_collected: bool, is_completed: bool) -> void:
	if is_completed:
		objective_label.text = "Ziel erreicht: der Leuchtturm leuchtet!"
	elif crystal_is_collected:
		objective_label.text = "Ziel: Kristall zum Leuchtturm bringen"
	elif gate_is_open:
		objective_label.text = "Ziel: Kristall hinter dem Tor einsammeln"
	else:
		objective_label.text = "Ziel: Schalter im Westen finden und Tor öffnen"


func update_interaction_hint(
	gate_is_open: bool,
	crystal_is_collected: bool,
	near_switch: bool,
	near_crystal: bool,
	near_lighthouse: bool
) -> void:
	if not gate_is_open and near_switch:
		message_label.text = "E drücken: Schalter aktivieren"
	elif gate_is_open and not crystal_is_collected and near_crystal:
		message_label.text = "E drücken: Kristall einsammeln"
	elif crystal_is_collected and near_lighthouse:
		message_label.text = "E drücken: Kristall im Leuchtturm einsetzen"
	else:
		message_label.text = "WASD / Pfeiltasten: bewegen    |    E: interagieren"


func show_completion_message() -> void:
	message_label.text = "Test geschafft! Schalter, Tor, Kristall und Leuchtturm funktionieren."
