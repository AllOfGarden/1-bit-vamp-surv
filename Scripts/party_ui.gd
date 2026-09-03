extends CanvasLayer
class_name PartyUI

## Toggleable in-game party roster (press "toggle_party_menu", bound to P).
## Lists every character registered with the Party autoload - portrait,
## name, live health bar - and clicking one calls Party.set_active() to make
## it the controlled character. The details panel shows that member's core
## stats plus an Equipment section. The equipment slots are placeholders on
## purpose: there's no item/inventory system yet, so this just reserves the
## UI space and shape for when one exists.

var panel: PanelContainer
var member_list: VBoxContainer
var details_label: Label
var equipment_icons: Array = []
var equipment_labels: Array = []
var selected_index := 0
var is_open := false

const SLOT_TYPES := [Item.ItemType.WEAPON, Item.ItemType.ARMOR, Item.ItemType.TRINKET]
const SLOT_NAMES := ["Weapon", "Armor", "Trinket"]

func _ready() -> void:
	layer = 10

	panel = PanelContainer.new()
	panel.visible = false
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.position = Vector2(12, 12)
	panel.custom_minimum_size = Vector2(220, 0)
	add_child(panel)

	var root_vbox := VBoxContainer.new()
	panel.add_child(root_vbox)

	var title := Label.new()
	title.text = "Party (P to close)"
	root_vbox.add_child(title)

	member_list = VBoxContainer.new()
	root_vbox.add_child(member_list)

	root_vbox.add_child(HSeparator.new())

	details_label = Label.new()
	details_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	root_vbox.add_child(details_label)

	var equip_title := Label.new()
	equip_title.text = "Equipment"
	root_vbox.add_child(equip_title)

	var equipment_row := HBoxContainer.new()
	root_vbox.add_child(equipment_row)
	for slot_name in SLOT_NAMES:
		var slot := PanelContainer.new()
		slot.custom_minimum_size = Vector2(48, 48)
		var slot_vbox := VBoxContainer.new()
		slot.add_child(slot_vbox)

		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(32, 32)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		slot_vbox.add_child(icon)
		equipment_icons.append(icon)

		var slot_label := Label.new()
		slot_label.text = slot_name
		slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot_vbox.add_child(slot_label)
		equipment_labels.append(slot_label)

		equipment_row.add_child(slot)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_party_menu"):
		is_open = !is_open
		panel.visible = is_open
		if is_open:
			refresh()

func _process(_delta: float) -> void:
	if is_open:
		_update_health_bars()
		_update_details()
		_update_equipment()

func refresh() -> void:
	for child in member_list.get_children():
		child.queue_free()

	for i in Party.members.size():
		var member = Party.members[i]
		if not is_instance_valid(member):
			continue
		member_list.add_child(_build_row(member, i))

	selected_index = Party.active_index
	_update_details()
	_update_equipment()

func _build_row(member: Node, index: int) -> Control:
	var row := HBoxContainer.new()

	var portrait := TextureRect.new()
	portrait.custom_minimum_size = Vector2(24, 24)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if member.has_node("Sprite2D"):
		portrait.texture = member.get_node("Sprite2D").texture
	row.add_child(portrait)

	var info := VBoxContainer.new()
	var name_label := Label.new()
	name_label.text = member.display_name if "display_name" in member else str(member.name)
	if "is_controlled" in member and member.is_controlled:
		name_label.text += " (active)"
	info.add_child(name_label)

	var hp_bar := ProgressBar.new()
	hp_bar.name = "HPBar"
	hp_bar.max_value = max(member.max_health, 1) if "max_health" in member else 1
	hp_bar.value = member.health if "health" in member else 0
	hp_bar.custom_minimum_size = Vector2(120, 12)
	hp_bar.show_percentage = false
	info.add_child(hp_bar)
	row.add_child(info)

	var select_btn := Button.new()
	select_btn.text = "Select"
	select_btn.pressed.connect(func():
		Party.set_active(index)
		selected_index = index
		refresh()
	)
	row.add_child(select_btn)

	return row

func _update_health_bars() -> void:
	for i in member_list.get_child_count():
		if i >= Party.members.size():
			continue
		var member = Party.members[i]
		if not is_instance_valid(member):
			continue
		var row: HBoxContainer = member_list.get_child(i)
		var info: VBoxContainer = row.get_child(1)
		var hp_bar: ProgressBar = info.get_node("HPBar")
		hp_bar.value = member.health if "health" in member else 0

func _update_details() -> void:
	if selected_index < 0 or selected_index >= Party.members.size():
		details_label.text = ""
		return
	var member = Party.members[selected_index]
	if not is_instance_valid(member):
		return
	var spd = member.move_speed if "move_speed" in member else 0
	var dmg = member.damage if "damage" in member else 0
	var hp = member.health if "health" in member else 0
	var max_hp = member.max_health if "max_health" in member else hp
	details_label.text = "Health: %d / %d\nSpeed: %.0f\nDamage: %d" % [hp, max_hp, spd, dmg]

## Shows real equipped items when the selected member has an `equipped`
## dict (currently just the Player) - falls back to empty labeled slots for
## anyone without an equipment system (e.g. party members, for now).
func _update_equipment() -> void:
	if selected_index < 0 or selected_index >= Party.members.size():
		return
	var member = Party.members[selected_index]
	if not is_instance_valid(member):
		return
	var equipped: Dictionary = member.equipped if "equipped" in member else {}
	for i in SLOT_TYPES.size():
		var slot_item = equipped.get(SLOT_TYPES[i]) if equipped else null
		if slot_item:
			equipment_icons[i].texture = slot_item.icon
			equipment_icons[i].visible = true
			equipment_labels[i].text = slot_item.item_name
		else:
			equipment_icons[i].visible = false
			equipment_labels[i].text = SLOT_NAMES[i]
