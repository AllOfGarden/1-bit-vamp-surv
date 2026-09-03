extends DamageCommand

var hit = false

func _on_area_entered(area: Area2D) -> void:
	var attacker = area.get_parent()
	if attacker == null:
		return
	hit = true
	execute(attacker, get_parent())
