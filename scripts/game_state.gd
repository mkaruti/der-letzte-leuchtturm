extends Node
## Zentraler Spielfortschritt fuer die laufende Spielsitzung.
## Autoload: GameState (siehe project.godot).
## In diesem Schritt gibt es noch KEIN Speichern auf Festplatte.

signal progress_changed

# Die drei kuenftigen Dungeon-Kristalle. Der aktuelle Insel-Testkristall
# hat bewusst die ID "prototype" und zaehlt NICHT zu diesen drei.
const DUNGEON_CRYSTAL_IDS = [&"forest", &"cave", &"ruins"]

var _collected_crystals: Dictionary = {}
var _delivered_crystals: Dictionary = {}


func collect_crystal(crystal_id: StringName) -> bool:
	if crystal_id == &"" or _collected_crystals.has(crystal_id):
		return false
	_collected_crystals[crystal_id] = true
	progress_changed.emit()
	return true


func has_crystal(crystal_id: StringName) -> bool:
	return _collected_crystals.has(crystal_id)


func deliver_crystal(crystal_id: StringName) -> bool:
	if not has_crystal(crystal_id) or _delivered_crystals.has(crystal_id):
		return false
	_delivered_crystals[crystal_id] = true
	progress_changed.emit()
	return true


func is_crystal_delivered(crystal_id: StringName) -> bool:
	return _delivered_crystals.has(crystal_id)


func get_delivered_dungeon_crystal_count() -> int:
	var total := 0
	for crystal_id in DUNGEON_CRYSTAL_IDS:
		if is_crystal_delivered(crystal_id):
			total += 1
	return total


func are_all_dungeon_crystals_delivered() -> bool:
	return get_delivered_dungeon_crystal_count() == DUNGEON_CRYSTAL_IDS.size()


func reset_progress() -> void:
	_collected_crystals.clear()
	_delivered_crystals.clear()
	progress_changed.emit()
