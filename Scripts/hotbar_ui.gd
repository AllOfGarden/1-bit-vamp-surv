extends CanvasLayer
class_name HotbarUI

## Bottom-of-screen spell hotbar. Number keys 1-4 pick which known spell is
## equipped on the current party leader; the existing cast_spell input
## (right-click) casts whatever's equipped. Shows each known spell's icon,
## mana cost, a cooldown cover, and the caster's mana bar.
##
## Hides itself gracefully if the active character has no SpellCaster (e.g.
## a party member without one) rather than erroring.

const BAR_TEXTURE_PATH := "res://Sprites/UI/UI.png"
const MAX_SLOTS := 4

var slots_box: HBoxContainer
var mana_bar: TextureProgressBar
var slot_data: Array = []  # {panel, cooldown_overlay}

func _ready() -> void:
	layer = 10

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	root.position = Vector2(-90, -56)
	add_child(root)

	var atlas: Texture2D = load(BAR_TEXTURE_PATH)

	var mana_bg := AtlasTexture.new()
	mana_bg.atlas = atlas
	mana_bg.region = Rect2(0, 128, 60, 14)
	var mana_fill := AtlasTexture.new()
	mana_fill.atlas = atlas
	mana_fill.region = Rect2(120, 128, 60, 14)  # the blue bar segment

	mana_bar = TextureProgressBar.new()
	mana_bar.texture_under = mana_bg
	mana_bar.texture_progress = mana_fill
	mana_bar.custom_minimum_size = Vector2(150, 14)
	mana_bar.fill_mode = TextureProgressBar.FILL_LEFT_TO_RIGHT
	root.add_child(mana_bar)

	slots_box = HBoxContainer.new()
	root.add_child(slots_box)

func _unhandled_input(event: InputEvent) -> void:
	for i in range(MAX_SLOTS):
		if event.is_action_pressed("spell_slot_%d" % (i + 1)):
			_select_slot(i)

func _process(_delta: float) -> void:
	var leader = Party.get_leader()
	if leader == null or not ("spell_caster" in leader) or leader.spell_caster == null:
		visible = false
		return
	visible = true

	var caster: SpellCaster = leader.spell_caster
	if slot_data.size() != mini(caster.known_spells.size(), MAX_SLOTS):
		_rebuild_slots(caster)

	mana_bar.max_value = max(caster.max_mana, 1)
	mana_bar.value = caster.mana

	for i in slot_data.size():
		var spell: Spell = caster.known_spells[i]
		var data = slot_data[i]
		var cd := caster.cooldown_remaining(spell)
		var frac: float = clamp(cd / max(spell.cooldown, 0.01), 0.0, 1.0)
		data.cooldown_overlay.visible = cd > 0.0
		data.cooldown_overlay.size = Vector2(28, 28.0 * frac)
		data.cooldown_overlay.position = Vector2(0, 28.0 * (1.0 - frac))
		data.panel.self_modulate = Color(1, 1, 0.6) if "equipped_spell" in leader and leader.equipped_spell == spell else Color(1, 1, 1)

func _select_slot(index: int) -> void:
	var leader = Party.get_leader()
	if leader == null or not ("spell_caster" in leader) or not ("equipped_spell" in leader):
		return
	var caster: SpellCaster = leader.spell_caster
	if index < caster.known_spells.size():
		leader.equipped_spell = caster.known_spells[index]

func _rebuild_slots(caster: SpellCaster) -> void:
	for child in slots_box.get_children():
		child.queue_free()
	slot_data.clear()

	for i in mini(caster.known_spells.size(), MAX_SLOTS):
		var spell: Spell = caster.known_spells[i]

		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(36, 48)
		slots_box.add_child(panel)

		var vbox := VBoxContainer.new()
		panel.add_child(vbox)

		var key_label := Label.new()
		key_label.text = str(i + 1)
		key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(key_label)

		var icon := TextureRect.new()
		icon.texture = spell.icon
		icon.custom_minimum_size = Vector2(28, 28)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		vbox.add_child(icon)

		var cooldown_overlay := ColorRect.new()
		cooldown_overlay.color = Color(0, 0, 0, 0.6)
		cooldown_overlay.custom_minimum_size = Vector2(28, 0)
		cooldown_overlay.visible = false
		icon.add_child(cooldown_overlay)  # sits on top of the icon, bottom-up as cooldown drains

		var cost_label := Label.new()
		cost_label.text = str(spell.mana_cost)
		cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(cost_label)

		slot_data.append({"panel": panel, "cooldown_overlay": cooldown_overlay})
