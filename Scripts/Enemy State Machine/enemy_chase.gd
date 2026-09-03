extends EnemyState
class_name EnemyChase

var direction

func Exit():
	anims.play("NPC Animations/RESET")

func Physics_Update(delta: float):
	
	if vision.entity:
		direction = vision.entity.global_position - enemy.global_position
		var dist = direction.length()
		var in_attack_range := false

		if stats.behavior == NPC.Behavior.RANGED:
			_update_ranged_movement(dist)
			in_attack_range = dist <= stats.preferred_range + 15
		else:
			enemy.velocity = enemy.velocity.move_toward(direction.normalized() * stats.speed, stats.accel)
			in_attack_range = dist < 10

		anims.play("NPC Animations/walk")
		
		if take_dmg.hit:
			#print_debug("goto hit", take_dmg.hit)
			Transitioned.emit(self, "takedamage")
		
		#If the enemy is within attack range (melee contact, or preferred range for ranged) they attack
		elif in_attack_range:
			if stats.behavior != NPC.Behavior.RANGED:
				enemy.velocity = Vector2.ZERO
			#print_debug("goto attack")
			Transitioned.emit(self, "enemyattack")
		
		#Change to idle state if out of vision range
	else:
		#print_debug("goto idle")
		Transitioned.emit(self, "enemyidle")


## Ranged enemies hold at stats.preferred_range instead of closing to melee -
## approach if too far, back off ("kite") if the target gets too close.
func _update_ranged_movement(dist: float) -> void:
	if dist < stats.preferred_range - 15:
		enemy.velocity = enemy.velocity.move_toward(-direction.normalized() * stats.speed, stats.accel)
	elif dist > stats.preferred_range + 15:
		enemy.velocity = enemy.velocity.move_toward(direction.normalized() * stats.speed, stats.accel)
	else:
		enemy.velocity = enemy.velocity.move_toward(Vector2.ZERO, stats.accel)
