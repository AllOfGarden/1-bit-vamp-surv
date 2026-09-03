extends CharacterBody2D
class_name PartyMember

const HealthBarScene := preload("res://Scenes/health_bar.tscn")

## A party member: player-controllable when active (swap with "swap_character"),
## and AI-controlled (follow the leader, auto-fight hostiles on contact) when
## benched. Deals and takes damage the same way Enemy/Player already do -
## contact-based, routed through DamageCommand, faction-checked - so it slots
## straight into the existing combat system with no special-casing.

@export var stats: NPC
@export var move_speed := 130.0
@export var accel := 10.0
@export var display_name := "Companion"

@onready var texture: Sprite2D = $Sprite2D
@onready var vision: Area2D = $Vision
@onready var camera: Camera2D = $Camera2D

var faction: int = Factions.FACTION.PLAYER  ## always player-aligned, regardless of stats.faction
var health: int
var max_health: int
var damage: int
var is_controlled: bool = false  ## set by Party manager

func _ready() -> void:
	if stats:
		texture.texture = stats.texture
		health = stats.health
		max_health = stats.health
		damage = stats.damage
	Party.register(self)

	var health_bar := HealthBarScene.instantiate()
	add_child(health_bar)
	health_bar.target = self

func _physics_process(_delta: float) -> void:
	if health <= 0:
		queue_free()
		return

	var direction := Vector2.ZERO

	if is_controlled:
		direction = Input.get_vector("left", "right", "up", "down")
	else:
		var leader = Party.get_leader()
		if leader != null and leader != self:
			direction = PartyFollowAI.get_direction(global_position, leader.global_position, vision.entity)

	if direction.x < 0:
		scale.y = -1
		rotation_degrees = 180
	elif direction.x > 0:
		scale.y = 1
		rotation_degrees = 0

	if !direction:
		velocity = velocity.move_toward(Vector2.ZERO, accel)
	else:
		velocity = velocity.move_toward(move_speed * direction, accel)

	move_and_slide()

func got_hit(attacker) -> void:
	health -= attacker.damage
	#print_debug("Party member hit! Health: ", health)
