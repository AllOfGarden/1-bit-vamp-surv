extends DamageCommand

var damage := 10

func _on_hitbox_body_entered(body: Node2D) -> void:
		execute(get_parent(), body)
