extends Node
## Zentraler Spielfortschritt fuer die laufende Spielsitzung.
## Autoload: GameState (siehe project.godot).
## In diesem Schritt gibt es noch KEIN Speichern auf Festplatte.

signal progress_changed

# Die drei echten Dungeon-Kristalle: Wald ist bereits spielbar,
# Höhle und Ruinen folgen in späteren Schritten.
const DUNGEON_CRYSTAL_IDS = [&"forest", &"cave", &"ruins"]

var _collected_crystals: Dictionary = {}
var _delivered_crystals: Dictionary = {}

# Rückkehr auf die Insel. Beide Dungeons benutzen dieselbe Rückkehrposition.
# Kristalle und Rätselstatus bleiben beim Szenenwechsel unverändert.
var island_return_position: Vector2 = Vector2(255, 640)
var island_gate_open: bool = false
var returning_from_forest: bool = false
var returning_from_cave: bool = false

# Gelöste Rätsel bleiben beim Szenenwechsel erhalten (nicht auf Festplatte).
var forest_puzzle_solved: bool = false
var cave_puzzle_solved: bool = false


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


func solve_forest_puzzle() -> void:
	if forest_puzzle_solved:
		return
	forest_puzzle_solved = true
	progress_changed.emit()


func solve_cave_puzzle() -> void:
	if cave_puzzle_solved:
		return
	cave_puzzle_solved = true
	progress_changed.emit()


func reset_progress() -> void:
	_collected_crystals.clear()
	_delivered_crystals.clear()
	island_return_position = Vector2(255, 640)
	island_gate_open = false
	returning_from_forest = false
	returning_from_cave = false
	forest_puzzle_solved = false
	cave_puzzle_solved = false
	progress_changed.emit()


func begin_forest_visit(return_position: Vector2, gate_is_open: bool) -> void:
	island_return_position = return_position
	island_gate_open = gate_is_open
	returning_from_forest = false
	returning_from_cave = false


func finish_forest_visit() -> void:
	returning_from_forest = true


func begin_cave_visit(return_position: Vector2, gate_is_open: bool) -> void:
	island_return_position = return_position
	island_gate_open = gate_is_open
	returning_from_cave = false
	returning_from_forest = false


func finish_cave_visit() -> void:
	returning_from_cave = true
