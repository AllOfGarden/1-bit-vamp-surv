extends DamageCommand
class_name Projectile

## Straight-line projectile. Damage goes through the same DamageCommand.execute()
## as every other hit in the game, so the faction guard applies automatically.
##
## `damage` and `faction` default to the shooter's own values (this is what
## ranged enemies use - the projectile just carries their stats). Spells set
## both explicitly instead, so a fireball deals the spell's damage using the
## caster's faction, not the caster's melee damage - the projectile itself
## becomes the "source" DamageCommand reads from.

var velocity: Vector2 = Vector2.ZERO
var shooter: Node = null   ## excluded from self-hits; also the default source of damage/faction below
var damage: int = 0
var faction: int = -1
var lifetime := 2.0

func _ready() -> void:
	if shooter:
		if damage == 0 and "damage" in shooter:
			damage = shooter.damage
		if faction == -1 and "faction" in shooter:
			faction = shooter.faction

func _physics_process(delta: float) -> void:
	self.global_position += velocity * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body == shooter:
		return  # spawns inside the caster's own shape - ignore, don't even destroy on this
	if body.has_method("got_hit"):
		execute(self, body)
	queue_free()  # always destroy on a real contact, even walls or a miss
