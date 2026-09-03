extends Node2D

## Attach this to the World node. On ready it measures however much of the
## Background TileMapLayer has been painted, then:
##   1. Clamps the player's camera to those bounds (no more walking into the void)
##   2. Builds four thin StaticBody2D walls around the edge so the player/enemies
##      can't physically leave the painted area
##
## Because this reads the actual painted tile bounds at runtime, you can keep
## expanding the hand-painted map in the editor and this will always match it -
## no hardcoded map size to update.

@export var wall_thickness := 16.0

@onready var background: TileMapLayer = $Background

func _ready() -> void:
	var used_rect: Rect2i = background.get_used_rect()
	if used_rect.size == Vector2i.ZERO:
		push_warning("World: Background TileMapLayer has no painted tiles yet - skipping bounds setup.")
		return

	var tile_size: Vector2 = background.tile_set.tile_size
	var map_origin: Vector2 = Vector2(used_rect.position) * tile_size
	var map_size: Vector2 = Vector2(used_rect.size) * tile_size
	var map_end: Vector2 = map_origin + map_size

	_setup_camera_limits(map_origin, map_end)
	_build_boundary_walls(map_origin, map_size)

func _setup_camera_limits(map_origin: Vector2, map_end: Vector2) -> void:
	var player := get_tree().get_first_node_in_group("Player")
	if player == null:
		push_warning("World: no node in group 'Player' found - camera limits not set.")
		return

	var camera: Camera2D = player.get_node_or_null("Camera2D")
	if camera == null:
		push_warning("World: player has no Camera2D child - camera limits not set.")
		return

	camera.limit_left = int(map_origin.x)
	camera.limit_top = int(map_origin.y)
	camera.limit_right = int(map_end.x)
	camera.limit_bottom = int(map_end.y)

func _build_boundary_walls(map_origin: Vector2, map_size: Vector2) -> void:
	var walls_container := Node2D.new()
	walls_container.name = "BoundaryWalls"
	add_child(walls_container)

	# Left, right, top, bottom - each a thin StaticBody2D strip just outside the painted area
	_add_wall(walls_container, Vector2(map_origin.x - wall_thickness / 2, map_origin.y + map_size.y / 2),
		Vector2(wall_thickness, map_size.y + wall_thickness * 2))
	_add_wall(walls_container, Vector2(map_origin.x + map_size.x + wall_thickness / 2, map_origin.y + map_size.y / 2),
		Vector2(wall_thickness, map_size.y + wall_thickness * 2))
	_add_wall(walls_container, Vector2(map_origin.x + map_size.x / 2, map_origin.y - wall_thickness / 2),
		Vector2(map_size.x + wall_thickness * 2, wall_thickness))
	_add_wall(walls_container, Vector2(map_origin.x + map_size.x / 2, map_origin.y + map_size.y + wall_thickness / 2),
		Vector2(map_size.x + wall_thickness * 2, wall_thickness))

func _add_wall(parent: Node2D, center: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = center
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	body.add_child(shape)
	parent.add_child(body)
