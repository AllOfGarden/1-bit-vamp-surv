extends CanvasLayer
class_name HudStats

## Bottom-left HUD: portrait, name, health bar, and mana bar for whoever the
## Party manager currently has under direct control. Mana bar hides itself
## gracefully if the active character has no SpellCaster (e.g. a party
## member without one) rather than erroring.

const BAR_TEXTURE_PATH := "res://Sprites/UI/UI.png"

var portrait: TextureRect
var name_label: Label
var health_bar: TextureProgressBar
var mana_bar: TextureProgressBar

func _ready() -> void:
	layer = 10

	var root := HBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	root.position = Vector2(12, -68)
	add_child(root)

	portrait = TextureRect.new()
	portrait.custom_minimum_size = Vector2(32, 32)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	root.add_child(portrait)

	var vbox := VBoxContainer.new()
	root.add_child(vbox)

	name_label = Label.new()
	vbox.add_child(name_label)

	var atlas: Texture2D = load(BAR_TEXTURE_PATH)

	var hp_bg := AtlasTexture.new()
	hp_bg.atlas = atlas
	hp_bg.region = Rect2(0, 128, 60, 14)
	var hp_fill := AtlasTexture.new()
	hp_fill.atlas = atlas
	hp_fill.region = Rect2(60, 128, 60, 14)

	health_bar = TextureProgressBar.new()
	health_bar.texture_under = hp_bg
	health_bar.texture_progress = hp_fill
	health_bar.custom_minimum_size = Vector2(120, 12)
	health_bar.fill_mode = TextureProgressBar.FILL_LEFT_TO_RIGHT
	vbox.add_child(health_bar)

	var mana_bg := AtlasTexture.new()
	mana_bg.atlas = atlas
	mana_bg.region = Rect2(0, 128, 60, 14)
	var mana_fill := AtlasTexture.new()
	mana_fill.atlas = atlas
	mana_fill.region = Rect2(120, 128, 60, 14)  # blue segment of the same bar strip

	mana_bar = TextureProgressBar.new()
	mana_bar.texture_under = mana_bg
	mana_bar.texture_progress = mana_fill
	mana_bar.custom_minimum_size = Vector2(120, 10)
	mana_bar.fill_mode = TextureProgressBar.FILL_LEFT_TO_RIGHT
	vbox.add_child(mana_bar)

func _process(_delta: float) -> void:
	var leader = Party.get_leader()
	if leader == null:
		visible = false
		return
	visible = true

	name_label.text = leader.display_name if "display_name" in leader else str(leader.name)
	if leader.has_node("Sprite2D"):
		portrait.texture = leader.get_node("Sprite2D").texture

	if "health" in leader and "max_health" in leader:
		health_bar.max_value = max(leader.max_health, 1)
		health_bar.value = leader.health
		health_bar.visible = true
	else:
		health_bar.visible = false

	if "spell_caster" in leader and leader.spell_caster != null:
		mana_bar.max_value = max(leader.spell_caster.max_mana, 1)
		mana_bar.value = leader.spell_caster.mana
		mana_bar.visible = true
	else:
		mana_bar.visible = false
