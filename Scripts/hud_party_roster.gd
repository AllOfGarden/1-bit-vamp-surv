extends CanvasLayer
class_name HudPartyRoster

## Bottom-right always-visible mini roster: every registered party member
## with a name and a tiny health bar, active one tinted. Complements the
## full party_ui.gd panel (P to open) rather than replacing it - this is
## the at-a-glance version, that one is the detailed/manage version.

const BAR_TEXTURE_PATH := "res://Sprites/UI/UI.png"

var list_box: VBoxContainer
var row_data: Array = []  # {container, bar}

func _ready() -> void:
	layer = 10
	list_box = VBoxContainer.new()
	list_box.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	list_box.grow_horizontal = Control.GROW_DIRECTION_BEGIN  # expand leftward, staying flush with the right edge
	list_box.grow_vertical = Control.GROW_DIRECTION_BEGIN    # expand upward, staying flush with the bottom edge
	list_box.position = Vector2(-12, -12)  # just the corner margin now - not a size guess
	add_child(list_box)

func _process(_delta: float) -> void:
	if row_data.size() != Party.members.size():
		_rebuild()

	for i in row_data.size():
		if i >= Party.members.size():
			continue
		var member = Party.members[i]
		if not is_instance_valid(member):
			continue
		var data = row_data[i]
		if "health" in member and "max_health" in member:
			data.bar.max_value = max(member.max_health, 1)
			data.bar.value = member.health
		var is_active: bool = "is_controlled" in member and member.is_controlled
		data.container.self_modulate = Color(1, 1, 0.6) if is_active else Color(1, 1, 1)

func _rebuild() -> void:
	for child in list_box.get_children():
		child.queue_free()
	row_data.clear()

	var atlas: Texture2D = load(BAR_TEXTURE_PATH)
	var bg := AtlasTexture.new()
	bg.atlas = atlas
	bg.region = Rect2(0, 128, 60, 14)
	var fill := AtlasTexture.new()
	fill.atlas = atlas
	fill.region = Rect2(60, 128, 60, 14)

	for member in Party.members:
		if not is_instance_valid(member):
			continue

		var row := HBoxContainer.new()
		list_box.add_child(row)

		var name_label := Label.new()
		name_label.text = member.display_name if "display_name" in member else str(member.name)
		name_label.custom_minimum_size = Vector2(60, 0)
		row.add_child(name_label)

		var bar := TextureProgressBar.new()
		bar.texture_under = bg
		bar.texture_progress = fill
		bar.custom_minimum_size = Vector2(60, 10)
		bar.fill_mode = TextureProgressBar.FILL_LEFT_TO_RIGHT
		row.add_child(bar)

		row_data.append({"container": row, "bar": bar})
