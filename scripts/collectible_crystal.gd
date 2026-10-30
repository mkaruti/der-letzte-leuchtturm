class_name CollectibleCrystal
extends Node2D
## Wiederverwendbarer Kristall für die spätere Insel und die Dungeons.
## Die Einsammelaktion wird weiterhin mit E durch die Hauptszene ausgelöst.

var is_collected: bool = false


func collect() -> bool:
	if is_collected:
		return false

	is_collected = true
	$Sprite2D.hide()
	return true
