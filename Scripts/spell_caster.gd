extends Node
class_name SpellCaster

## Attach to anything that should be able to cast spells. Structured like
## Inventory: a self-contained component the owning character calls into,
## rather than logic baked into player.gd directly - so party members could
## get one later without duplicating any of this.

signal spell_cast(spell: Spell)
signal cast_failed(spell: Spell, reason: String)

const ProjectileScene := preload("res://Scenes/projectile.tscn")

@export var known_spells: Array[Spell] = []
@export var max_mana: int = 100
@export var mana_regen_per_sec: float = 5.0

var mana: float

var _cooldowns: Dictionary = {}  # Spell -> remaining seconds

func _ready() -> void:
	mana = max_mana

func _process(delta: float) -> void:
	for spell in _cooldowns.keys():
		_cooldowns[spell] = max(0.0, _cooldowns[spell] - delta)
	mana = min(mana + mana_regen_per_sec * delta, max_mana)

func cooldown_remaining(spell: Spell) -> float:
	return _cooldowns.get(spell, 0.0)

func can_cast(spell: Spell) -> bool:
	return mana >= spell.mana_cost and cooldown_remaining(spell) <= 0.0

## caster: the character casting - needs global_position; faction/damage/health
## are read where relevant to the spell's effect type.
func cast(spell: Spell, caster: Node2D) -> bool:
	if not can_cast(spell):
		var reason := "on cooldown" if cooldown_remaining(spell) > 0.0 else "not enough mana"
		cast_failed.emit(spell, reason)
		return false

	mana -= spell.mana_cost
	_cooldowns[spell] = spell.cooldown

	match spell.effect_type:
		Spell.EffectType.PROJECTILE:
			_cast_projectile(spell, caster)
		Spell.EffectType.HEAL:
			_cast_heal(spell, caster)
		_:
			push_warning("SpellCaster: effect type not implemented yet for '%s'" % spell.spell_name)

	spell_cast.emit(spell)
	return true

func _target_position(spell: Spell, caster: Node2D) -> Vector2:
	match spell.target_mode:
		Spell.TargetMode.AIMED:
			return caster.get_global_mouse_position()
		Spell.TargetMode.SELF:
			return caster.global_position
		_:
			push_warning("SpellCaster: target mode '%s' not implemented yet, aiming at mouse instead" % spell.target_mode)
			return caster.get_global_mouse_position()

func _cast_projectile(spell: Spell, caster: Node2D) -> void:
	var target_pos := _target_position(spell, caster)
	var proj := ProjectileScene.instantiate()
	proj.global_position = caster.global_position
	proj.shooter = caster
	proj.damage = spell.damage
	if "faction" in caster:
		proj.faction = caster.faction
	var dir: Vector2 = target_pos - caster.global_position
	proj.velocity = (dir.normalized() if dir.length() > 0.1 else Vector2.RIGHT) * spell.projectile_speed
	caster.get_tree().current_scene.add_child(proj)

func _cast_heal(spell: Spell, caster: Node2D) -> void:
	if "health" in caster and "max_health" in caster:
		caster.health = min(caster.health + spell.heal_amount, caster.max_health)
