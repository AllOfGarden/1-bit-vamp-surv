extends DamageCommand

func _on_body_entered(body: Node2D) -> void:
	execute(get_parent(), body)
