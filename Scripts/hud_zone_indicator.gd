extends CanvasLayer
class_name HudZoneIndicator

## Top-right always-visible zone name + difficulty. Reads the Player node's
## current_zone directly (set by MapZone on enter/exit) rather than
## Party.get_leader(), since zone tracking is tied to the physical Player
## body specifically - it keeps moving via follow-AI even when benched, so
## it's the correct source regardless of who's actively controlled.
## Hides itself when standing outside any zone.

var label: Label

func _ready() -> void:
	layer = 10
	label = Label.new()
	label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	label.position = Vector2(-160, 12)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(label)

func _process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("Player")
	if player == null or not ("current_zone" in player) or player.current_zone == null:
		visible = false
		return
	visible = true
	var zone: MapZone = player.current_zone
	label.text = "%s\nDifficulty %d" % [zone.zone_name, zone.difficulty]
