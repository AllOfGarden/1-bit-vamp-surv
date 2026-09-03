extends Node2D
class_name HealthBar

## Floating health bar that stays above whatever it's tracking, unaffected by
## the target's own flip/rotation (targets mirror via scale.y=-1 + 180°
## rotation, which would otherwise flip the bar upside down too).

@export var height_offset: float = -14.0

@onready var bar: TextureProgressBar = $TextureProgressBar

var target: Node2D = null

func _ready() -> void:
	top_level = true  # ignore the parent's transform entirely

func _process(_delta: float) -> void:
	if target == null or not is_instance_valid(target):
		queue_free()
		return

	global_position = target.global_position + Vector2(0, height_offset)
	rotation = 0
	scale = Vector2(0.35, 0.35)

	if "health" in target and "max_health" in target:
		var max_hp = max(target.max_health, 1)
		bar.max_value = max_hp
		bar.value = target.health
		visible = target.health > 0
