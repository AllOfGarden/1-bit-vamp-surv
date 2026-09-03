extends Node
class_name Inventory

signal item_added(item: Item)
signal item_removed(item: Item)

@export var capacity: int = 20
var items: Array = []

func add_item(item: Item) -> bool:
	if items.size() >= capacity:
		return false
	items.append(item)
	item_added.emit(item)
	return true

func remove_item(item: Item) -> void:
	if item in items:
		items.erase(item)
		item_removed.emit(item)
