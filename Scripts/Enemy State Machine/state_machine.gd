extends EnemyState

@export var initial_state : EnemyState

var current_state : EnemyState
var states : Dictionary = {}
var parent : CharacterBody2D

#Place all enemy states inside an array
func init(parent, vision, anims, hitbox, hurtbox, stats):
	for child in get_children():
		if child is EnemyState:
			child.entity = parent
			child.vision = vision
			child.anims = anims
			child.take_dmg = hurtbox
			child.hitbox = hitbox
			child.stats = stats
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
	
	#Set initial state set in editor to current state
	if initial_state:
		initial_state.Enter()
		current_state = initial_state
	
	
	
#If in a state call that states update function
func _process(delta: float) -> void:
	if current_state:
		current_state.Update(delta)
	
	
#If in a state call that states physics update function
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.Physics_Update(delta)
	
#Update to new state when signal emitted
func on_child_transition(state, new_state_name):
	if state != current_state:
		return
	
	#Assign new state
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
		
	#Exit current state
	if current_state:
		current_state.Exit()
		pass
	#Enter new state
	new_state.Enter()
	
	#Set current state to the state just entered
	current_state = new_state
	#print("Current State: ", current_state)


func _on_vision_body_entered(body: Node2D) -> void:
	if body != get_parent():
		entity = body
