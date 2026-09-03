extends CharacterBody2D
class_name Enemy

const ItemPickupScene := preload("res://Scenes/item_pickup.tscn")
const HealthBarScene := preload("res://Scenes/health_bar.tscn")

@onready var texture : Sprite2D = $Sprite2D
@onready var state_machine : Node = $"State Machine"
@onready var vision : Area2D = $Vision
@onready var hurtbox : Area2D = $Hurtbox
@onready var hitbox : Area2D = $Hitbox
@onready var anim_flip : Node2D = $Sprite2D/AnimFlip
@onready var anims : AnimationPlayer = $Sprite2D/AnimFlip/AnimationPlayer

@export var stats: NPC

var dmg_cd := 0.3
var health : int
var max_health : int
var speed : float
var accel : float
var damage : int
var faction : int
var cloned_stats

func _ready() -> void:
	cloned_stats = stats.duplicate()
	texture.texture = cloned_stats.texture
	health = cloned_stats.health
	max_health = cloned_stats.health
	speed = cloned_stats.speed
	accel = cloned_stats.accel
	damage = cloned_stats.damage
	faction = cloned_stats.faction
	add_to_group(cloned_stats.group)
	state_machine.init(self, vision, anims, hitbox, hurtbox, cloned_stats)

	var health_bar := HealthBarScene.instantiate()
	add_child(health_bar)
	health_bar.target = self

 
func _physics_process(_delta: float) -> void:
	
	#var last_facing_dir = 1
	#print(hurtbox.hit)
	
	#Flips sprite based on direction
	if velocity.x > 0:
		$".".scale.y = 1
		$".".rotation_degrees = 0
		
	elif velocity.x < 0:
		$".".scale.y = -1
		$".".rotation_degrees = 180
		
	if health <= 0:
		_die()
		return
	
	move_and_slide()

func got_hit(attacker):
	health -= attacker.damage
	#print_debug("Ouch! Health: ", health)

func _die() -> void:
	if cloned_stats and cloned_stats.drop_table.size() > 0 and randf() < cloned_stats.drop_chance:
		var drop: Item = cloned_stats.drop_table.pick_random()
		var pickup := ItemPickupScene.instantiate()
		pickup.item = drop
		pickup.global_position = global_position
		get_tree().current_scene.add_child(pickup)
	queue_free()
