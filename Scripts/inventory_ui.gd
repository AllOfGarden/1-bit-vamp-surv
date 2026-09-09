extends Control
class_name InventoryUI

const SLOT_TYPES := [Item.ItemType.WEAPON, Item.ItemType.ARMOR, Item.ItemType.TRINKET]
const SLOT_NAMES := ["Weapon", "Armor", "Trinket"]

@onready var panel : Panel = $Panel
@onready var equipped_box : VBoxContainer = $Panel/Root/EquippedBox
@onready var stash_box : VBoxContainer = $Panel/Root/ScrollContainer/StashBox
var is_open := false
var _last_count := -1

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		is_open = !is_open
		panel.visible = is_open
		if is_open:
			refresh()

func refresh() -> void:
	var player := get_tree().get_first_node_in_group("Player")
	if player == null or not ("inventory" in player) or not ("equipped" in player):
		return
 
	for child in equipped_box.get_children():
		child.queue_free()
	for child in stash_box.get_children():
		child.queue_free()
	
	for i in SLOT_TYPES.size():
		var item: Item = player.equipped.get(SLOT_TYPES[i])
		var row := HBoxContainer.new()
	
		var slot_label := Label.new()
		slot_label.custom_minimum_size = Vector2(70, 0)
		slot_label.text = SLOT_NAMES[i] + ":"
		row.add_child(slot_label)
	
		var value_label := Label.new()
		value_label.text = item.item_name if item else "(empty)"
		row.add_child(value_label)
	
		equipped_box.add_child(row)
	
	_last_count = player.inventory.items.size()
 
	if player.inventory.items.is_empty():
		var empty_label := Label.new()
		empty_label.text = "(nothing stashed)"
		stash_box.add_child(empty_label)
		return
 
	for item in player.inventory.items:
		stash_box.add_child(_build_item_row(item, player))
 
func _build_item_row(item: Item, player: Node) -> Control:
	var row := HBoxContainer.new()
	
	var icon := TextureRect.new()
	icon.texture = item.icon
	icon.custom_minimum_size = Vector2(20, 20)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(icon)
	
	var name_label := Label.new()
	name_label.text = item.item_name
	name_label.custom_minimum_size = Vector2(110, 0)
	row.add_child(name_label)
	
	var stats_label := Label.new()
	stats_label.text = item.get_stat_summary()
	stats_label.custom_minimum_size = Vector2(90, 0)
	row.add_child(stats_label)
	
	var equip_btn := Button.new()
	equip_btn.text = "Equip"
	equip_btn.pressed.connect(func():
		player.equip_item(item)
		refresh()
	)
	row.add_child(equip_btn)
	
	return row
