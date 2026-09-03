extends Area2D
class_name ItemPickup

@export var item: Item

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	if item and item.icon:
		sprite.texture = item.icon

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("collect_item"):
		if body.collect_item(item):
			queue_free()
