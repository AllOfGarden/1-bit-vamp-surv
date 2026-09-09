extends Resource
class_name Item

enum ItemType { WEAPON, ARMOR, TRINKET }

@export var item_name := "Unknown Item"
@export var icon: Texture2D
@export var type: ItemType = ItemType.TRINKET
@export var description := ""

@export_category("Stat Bonuses")
@export var damage_bonus: int = 0
@export var max_health_bonus: int = 0
@export var speed_bonus: float = 0.0

## Returns a short comma-separated summary of this item's non-zero stat
## bonuses, e.g. "+8 dmg, +25 spd" - used anywhere an item needs to describe
## itself (inventory rows, equipment tooltips, etc.) so that display logic
## lives in one place instead of being copy-pasted per UI script.
func get_stat_summary() -> String:
	var parts: Array = []
	if damage_bonus != 0:
		parts.append("+%d dmg" % damage_bonus)
	if max_health_bonus != 0:
		parts.append("+%d hp" % max_health_bonus)
	if speed_bonus != 0.0:
		parts.append("+%.0f spd" % speed_bonus)
	return ", ".join(parts)
