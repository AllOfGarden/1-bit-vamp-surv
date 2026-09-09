extends CharacterBody2D
class_name Player

@export var move_speed = 150.0
@export var accel = 10
@export var attack_speed = 0.2
@export var damage = 10
@export var health = 50
@export var faction: int = Factions.FACTION.PLAYER
@export var display_name := "Hero"
var max_health: int

@onready var player_anim_tree: AnimationTree = $AnimationTree
@onready var player_sprite: Sprite2D = $Sprite2D
@onready var weapon_sprite: Sprite2D = $Weapon
@onready var wep_hitbox: Area2D = $Weapon/Hitbox
@onready var inventory: Inventory = $Inventory
@onready var spell_caster: SpellCaster = $SpellCaster

@export var equipped_spell: Spell  ## cast with the spell input - a full spellbook/selection UI is future work

var enemy = null
var can_attack = true
var weapon_hit = false
var current_zone: MapZone = null  ## Set/cleared by MapZone when the player enters/exits one
var is_controlled: bool = true    ## Set by Party manager - false when a party member is active instead

var base_damage: int
var base_move_speed: float
var base_max_health: int
var equipped: Dictionary = {}  ## Item.ItemType -> Item, currently worn gear

var enemy_scene : PackedScene = preload("res://Scenes/enemy.tscn")

var enemy_stats : Array[NPC] = [
	preload("res://Enemies/Resources/demon.tres"),
	preload("res://Enemies/Resources/goblin.tres")
]

func _ready() -> void:
	weapon_sprite.visible = false
	wep_hitbox.monitorable = false
	wep_hitbox.monitoring = false
	$Weapon/Hitbox/CollisionShape2D.disabled = false
	base_damage = damage
	base_move_speed = move_speed
	base_max_health = health
	max_health = health
	Party.register(self)

## Called by ItemPickup. Auto-equips into an empty slot of the matching type;
## otherwise stashes it in the inventory for later. Returns true if the item
## was taken off the ground either way.
func collect_item(item: Item) -> bool:
	if equipped.get(item.type) == null:
		equipped[item.type] = item
		_recompute_stats()
		return true
	return inventory.add_item(item)

func equip_item(item: Item) -> void:
	var previous = equipped.get(item.type)
	if previous:
		inventory.add_item(previous)
	equipped[item.type] = item
	inventory.remove_item(item)
	_recompute_stats()

func unequip_item(item_type: int) -> void:
	var item = equipped.get(item_type)
	if item:
		inventory.add_item(item)
		equipped.erase(item_type)
		_recompute_stats()

func _recompute_stats() -> void:
	damage = base_damage
	move_speed = base_move_speed
	max_health = base_max_health
	for item in equipped.values():
		if item == null:
			continue
		damage += item.damage_bonus
		move_speed += item.speed_bonus
		max_health += item.max_health_bonus
	health = min(health, max_health)

func _physics_process(delta: float) -> void:

	var direction := Vector2.ZERO

	if is_controlled:
		direction = Input.get_vector("left", "right", "up", "down")
		var attack := Input.is_action_just_pressed("mouse1")
		var cast := Input.is_action_just_pressed("cast_spell")
		var spawn := Input.is_action_just_pressed("ui_accept")

		#Animates weapon when attacking
		if attack:
			draw_weapon()

		if cast and equipped_spell:
			spell_caster.cast(equipped_spell, self)

		if spawn:
			var pool := enemy_stats
			if current_zone != null and current_zone.enemy_pool.size() > 0:
				pool = current_zone.enemy_pool
			spawn_enemy(pool.pick_random())
	else:
		var leader = Party.get_leader()
		if leader != null and leader != self:
			direction = PartyFollowAI.get_direction(global_position, leader.global_position, null)

	#Flips sprite based on direction
	if direction.x < 0:
		$".".scale.y = -1
		$".".rotation_degrees = 180

	elif direction.x > 0:
		$".".scale.y = 1
		$".".rotation_degrees = 0

	#Move based on input (or follow-AI direction) and play walk cycle
	if !direction:
		velocity = velocity.move_toward(Vector2.ZERO, accel)
		player_anim_tree.set("parameters/Walking/blend_position", -1)

	else:
		velocity = velocity.move_toward(move_speed * direction, accel)
		player_anim_tree.set("parameters/Walking/blend_position", 1)

	move_and_slide()

#Function to animate the weapon in the direction the player is pointing their mouse
func draw_weapon():
	
	var set_wep_dir = get_local_mouse_position()
	var draw_wep
	var wep_angle
	var tween
	var flip_wep
	
	
	#If the player can attack
	if can_attack:
		can_attack = false
		tween = weapon_sprite.create_tween()
		
		wep_hitbox.monitoring = true
		wep_hitbox.monitorable = true
		$Weapon/Hitbox/CollisionShape2D.disabled = false
		
		#Gets unit vector from the sprite to the mouse
		set_wep_dir = set_wep_dir.normalized()
		
		#Flips weapon sprite
		if set_wep_dir.x < 0:
			weapon_sprite.scale.y = -1
			flip_wep = -1
			
		else:
			weapon_sprite.scale.y = 1
			flip_wep = 1
		
		#Finds the direction of the vector and draws the sprite tilted 45 degrees
		wep_angle = atan2(set_wep_dir.y, set_wep_dir.x) - (flip_wep * PI/4)
		weapon_sprite.set_rotation(wep_angle)
		
		#Swap to degrees here because for some reason using radians caused unintended behavior with the animation
		wep_angle = rad_to_deg(wep_angle)
		
		#Give the vector magnitude seven so it draws the weapon in a circle around the player
		#Add -5 to the y component to match the offset of the player sprite
		draw_wep = (set_wep_dir * 7) + Vector2(0, -5)
		
		#Sets position of the weapon sprite to the (x,y) coords of the vector
		weapon_sprite.position = draw_wep
		
		#Change wep angle for the tween
		wep_angle = wep_angle + (flip_wep * 180)
		
		#Toggle visiblity on and tween the weapon(swing) then toggle visibility off
		weapon_sprite.visible = true
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property($Weapon, "rotation_degrees", wep_angle, 0.2)
		await tween.finished
		weapon_sprite.visible = false
		wep_hitbox.monitoring = false
		wep_hitbox.monitorable = false
		$Weapon/Hitbox/CollisionShape2D.disabled = true
		
		#Create timer to signal when the player can attack again
		get_tree().create_timer(attack_speed).timeout.connect(func(): can_attack = true)
		

func spawn_enemy(stats: NPC):
	var spawned_enemy : Enemy = enemy_scene.instantiate()
	spawned_enemy.stats = stats
	add_sibling(spawned_enemy)
	spawned_enemy.global_position = get_global_mouse_position()

func got_hit(attacker) -> void:
	health -= attacker.damage

func _on_body_entered(body: Node2D) -> void:
	enemy = body
	weapon_hit = true
