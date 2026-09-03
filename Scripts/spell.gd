extends Resource
class_name Spell

enum TargetMode { AIMED, SELF, NEAREST_ENEMY, PARTY }
enum EffectType { PROJECTILE, HEAL, AOE, BUFF }

@export var spell_name := "Spell"
@export var icon: Texture2D
@export var mana_cost: int = 10
@export var cooldown: float = 1.0
@export var target_mode: TargetMode = TargetMode.AIMED
@export var effect_type: EffectType = EffectType.PROJECTILE

@export_category("Projectile Effect")
@export var damage: int = 0
@export var projectile_speed: float = 250.0

@export_category("Heal Effect")
@export var heal_amount: int = 0
