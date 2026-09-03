extends Resource
class_name NPC

enum Behavior { MELEE, RANGED }

@export var texture: Texture2D

@export var group: String
@export var faction: int
@export var behavior: Behavior = Behavior.MELEE

@export_category("Stats")
@export var health: int
@export var speed: float
@export var accel: float
@export var damage: int

@export_category("Ranged Behavior")
@export var preferred_range: float = 90.0   ## only used when behavior == RANGED - distance it tries to hold from its target
@export var projectile_speed: float = 220.0

@export_category("Drops")
@export var drop_table: Array[Item] = []
@export var drop_chance: float = 0.5
