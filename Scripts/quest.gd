extends Resource
class_name Quest

## A single quest's definition + runtime progress. Same shape as Item/Spell/NPC:
## author it as a .tres, hand it to QuestLog.start_quest().
##
## target_group's meaning depends on objective_type:
##   KILL_COUNT   -> an Enemy's cloned_stats.group (e.g. "goblin")
##   REACH_ZONE   -> a MapZone's zone_name
##   COLLECT_ITEM -> an Item's item_name
##   CUSTOM       -> whatever the caller decides - report_event() just needs a matching string

enum ObjectiveType { KILL_COUNT, REACH_ZONE, COLLECT_ITEM, CUSTOM }
enum Status { INACTIVE, ACTIVE, COMPLETE }

@export var quest_name := "Unnamed Quest"
@export_multiline var description := ""

@export_category("Objective")
@export var objective_type: ObjectiveType = ObjectiveType.KILL_COUNT
@export var target_group := ""
@export var target_amount: int = 1

@export_category("Reward")
@export var reward_item: Item    ## optional - QuestLog just signals completion, granting is up to the listener
@export var reward_spell: Spell  ## optional, same deal

var status: Status = Status.INACTIVE
var progress: int = 0
