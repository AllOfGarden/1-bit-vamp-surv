extends EnemyState
class_name EnemyIdle

var move_direction : Vector2
var wander_time : float
var wait_time : float
var direction

#Randomize wander direction and duration
func randomize_wander():
	move_direction = Vector2(randf_range(-1,1), randf_range(-1, 1)).normalized()
	wander_time = randf_range(1, 3)
	wait_time = randf_range(1, 3)

#Assign player node and run randomize function
func Enter():
	randomize_wander()

#Countdown wander timer then randomize again when timer hits 0
func Update(delta: float):
	if wander_time > 0:
		wander_time -= delta
		anims.play("NPC Animations/walk")
	elif wait_time > 0:
		move_direction = Vector2.ZERO
		wait_time -= delta
		anims.play("NPC Animations/RESET")
	else:
		randomize_wander()

#Sets enemy velocity and compares player position to self
func Physics_Update(delta: float): 
	#var alignment = Globals.get_alignment(.faction, entity.faction)
	
	#print_debug(alignment)
	if vision.entity: #and alignment == "hostile":
		#print_debug("goto chase")
		Transitioned.emit(self, "enemychase")
		
	elif take_dmg.hit:
		#print_debug("goto hit", take_dmg.hit)
		Transitioned.emit(self, "takedamage")
		
	else:
		enemy.velocity = enemy.velocity.move_toward(move_direction * stats.speed, stats.accel)
