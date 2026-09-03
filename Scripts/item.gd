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
