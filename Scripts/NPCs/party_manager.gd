extends Node

## Autoloaded as "Party". Any controllable character (Player, PartyMember)
## calls Party.register(self) in its own _ready(). Pressing the
## "swap_character" action cycles which one is under direct input control;
## everyone else falls back to PartyFollowAI behavior.

var members: Array = []
var active_index := 0

func register(member: Node) -> void:
	members.append(member)
	# First one registered starts in control (normally the Player).
	if members.size() == 1:
		active_index = 0
	_apply_active()

func get_leader() -> Node:
	if members.is_empty():
		return null
	return members[active_index]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("swap_character") and members.size() > 1:
		set_active((active_index + 1) % members.size())

## Directly select a member by index - used by the party manager UI.
func set_active(index: int) -> void:
	if index < 0 or index >= members.size():
		return
	active_index = index
	_apply_active()

func _apply_active() -> void:
	for i in members.size():
		var m = members[i]
		if not is_instance_valid(m):
			continue
		m.is_controlled = (i == active_index)
		if m.is_controlled and m.has_node("Camera2D"):
			m.get_node("Camera2D").make_current()
