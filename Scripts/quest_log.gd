extends Node
class_name QuestLog

## Attach to whatever should track quests (Player, most likely). Same
## component pattern as Inventory/SpellCaster - the owner calls into this
## rather than quest logic living in player.gd directly.
##
## Deliberately does NOT grant rewards or know about Inventory/SpellCaster -
## that's a real design decision (auto-grant? require turning in to an NPC?)
## left for whoever wires this in. Listen to quest_completed and apply
## quest.reward_item / quest.reward_spell yourself when you're ready.

signal quest_started(quest: Quest)
signal quest_progress(quest: Quest, progress: int, target: int)
signal quest_completed(quest: Quest)

var active_quests: Array = []
var completed_quests: Array = []

func start_quest(quest: Quest) -> void:
	if quest in active_quests or quest in completed_quests:
		return
	quest.status = Quest.Status.ACTIVE
	quest.progress = 0
	active_quests.append(quest)
	quest_started.emit(quest)

## Call this from wherever the relevant game event already happens - e.g.
## Enemy._die() for KILL_COUNT, MapZone entry for REACH_ZONE, ItemPickup
## collection for COLLECT_ITEM. Matches any active quest with the same
## objective_type + target_group, so callers don't need to know which
## quests (if any) currently care about the event.
##
## Example call sites you'd add later:
##   demon.gd  _die():           quest_log.report_event(Quest.ObjectiveType.KILL_COUNT, cloned_stats.group)
##   map_zone.gd  _on_body_entered(player): quest_log.report_event(Quest.ObjectiveType.REACH_ZONE, zone_name)
##   item_pickup.gd  _on_body_entered():    quest_log.report_event(Quest.ObjectiveType.COLLECT_ITEM, item.item_name)
func report_event(objective_type: int, target_group: String, amount: int = 1) -> void:
	for quest in active_quests:
		if quest.objective_type == objective_type and quest.target_group == target_group:
			quest.progress = min(quest.progress + amount, quest.target_amount)
			quest_progress.emit(quest, quest.progress, quest.target_amount)
			if quest.progress >= quest.target_amount:
				_complete(quest)

func _complete(quest: Quest) -> void:
	quest.status = Quest.Status.COMPLETE
	active_quests.erase(quest)
	completed_quests.append(quest)
	quest_completed.emit(quest)
