extends Area2D
class_name MapZone

## Drop this as an Area2D (with a CollisionShape2D child covering the region)
## into world.tscn over any hand-painted area you want to give distinct identity -
## a biome, a difficulty tier, a point of interest, whatever.
##
## Draw the shape to roughly match the painted region's footprint. Give it a
## name and an enemy pool. As long as zones don't overlap, whichever one the
## player is standing in drives what spawn_enemy() picks from.

@export var zone_name := "Unnamed Zone"
@export var difficulty := 1
@export var enemy_pool: Array[NPC] = []
@export var is_point_of_interest := false

func _ready() -> void:
	monitoring = true
	monitorable = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and "current_zone" in body:
		body.current_zone = self

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") and "current_zone" in body and body.current_zone == self:
		body.current_zone = null
