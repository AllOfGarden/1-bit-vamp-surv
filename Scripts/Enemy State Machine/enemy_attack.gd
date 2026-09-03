extends EnemyState
class_name EnemyAttack

const ProjectileScene := preload("res://Scenes/projectile.tscn")

var can_attack : bool
var direction
var attack_cooldown := 0.0


func Enter():
	anims.play("NPC Animations/attack")
	if stats.behavior == NPC.Behavior.RANGED and vision.entity:
		direction = vision.entity.global_position - enemy.global_position
		_fire_projectile()
		attack_cooldown = 1.0

func Exit():
	anims.play("NPC Animations/RESET")

func Physics_Update(delta: float):
	if take_dmg.hit:
		#print_debug("goto hit", take_dmg.hit)
		Transitioned.emit(self, "takedamage")
		return

	if not vision.entity:
		#print_debug("goto idle")
		Transitioned.emit(self, "enemyidle")
		return

	direction = vision.entity.global_position - enemy.global_position

	if stats.behavior == NPC.Behavior.RANGED:
		attack_cooldown -= delta
		if direction.length() > stats.preferred_range + 30:
			#print_debug("goto chase")
			Transitioned.emit(self, "enemychase")
		elif attack_cooldown <= 0.0:
			_fire_projectile()
			attack_cooldown = 1.0
	else:
		if direction.length() > 15:
			#print_debug("goto chase")
			Transitioned.emit(self, "enemychase")


func _fire_projectile() -> void:
	var proj := ProjectileScene.instantiate()
	proj.global_position = enemy.global_position
	proj.shooter = enemy
	proj.velocity = direction.normalized() * stats.projectile_speed if direction else Vector2.RIGHT * stats.projectile_speed
	enemy.get_tree().current_scene.add_child(proj)
