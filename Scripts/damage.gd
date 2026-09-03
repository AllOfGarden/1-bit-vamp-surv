extends Node
class_name DamageCommand

func execute(source, target):
	if target == source:
		return
	if "faction" in source and "faction" in target:
		if Globals.get_alignment(source.faction, target.faction) != "hostile":
			return
	#print_debug(source, " hit ", target, " for ", source.damage, " damage")
	target.got_hit(source)
