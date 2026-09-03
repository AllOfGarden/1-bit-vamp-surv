extends EnemyState
class_name TakeDamage

var wait : bool

func Enter():
	enemy.velocity = Vector2.ZERO
	take_dmg.monitoring = false
	take_dmg.hit = false
	wait = true
	anims.play("NPC Animations/take damage")
	get_tree().create_timer(0.4).timeout.connect(func(): wait = false)
	

func Exit():
	take_dmg.monitoring = true
	anims.play("NPC Animations/RESET")
	

func Physics_Update(delta):
	if !wait:
		#print_debug("goto chase")
		Transitioned.emit(self, "enemychase")
