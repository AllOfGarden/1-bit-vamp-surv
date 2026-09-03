extends Area2D

## Tracks every currently-overlapping hostile body (not just the last one to
## enter) so that one target leaving vision range doesn't clear tracking of
## another still-present hostile target. `entity` is computed on read as the
## nearest currently-valid hostile body.

var visible_entities: Array = []

var entity:
	get:
		return _closest_entity()


func _on_body_entered(body: Node2D) -> void:
	if body != get_parent() and "faction" in body and "faction" in get_parent():
		var self_faction = get_parent().faction
		if Globals.get_alignment(self_faction, body.faction) == "hostile":
			if body not in visible_entities:
				visible_entities.append(body)


func _on_body_exited(body: Node2D) -> void:
	visible_entities.erase(body)


func _closest_entity() -> Variant:
	visible_entities = visible_entities.filter(func(b): return is_instance_valid(b))
	if visible_entities.is_empty():
		return null

	var self_pos: Vector2 = get_parent().global_position
	var closest = visible_entities[0]
	var closest_dist := self_pos.distance_squared_to(closest.global_position)
	for body in visible_entities:
		var d := self_pos.distance_squared_to(body.global_position)
		if d < closest_dist:
			closest = body
			closest_dist = d
	return closest
