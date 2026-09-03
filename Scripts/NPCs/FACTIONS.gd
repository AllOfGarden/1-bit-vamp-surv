extends Node
class_name Factions

enum FACTION {
	PLAYER,
	HUMAN,
	DEMON,
	GOBLIN
}

var faction_relationships = {
	FACTION.PLAYER: {       #0
		FACTION.PLAYER: "friendly",
		FACTION.HUMAN: "friendly",
		FACTION.DEMON: "hostile",
		FACTION.GOBLIN: "hostile"
	},
	
	FACTION.HUMAN: {        #1
		FACTION.PLAYER: "friendly",
		FACTION.HUMAN: "friendly",
		FACTION.DEMON: "hostile",
		FACTION.GOBLIN: "hostile"
	},
	
	FACTION.DEMON: {        #2
		FACTION.PLAYER: "hostile",
		FACTION.HUMAN: "hostile",
		FACTION.DEMON: "friendly",
		FACTION.GOBLIN: "friendly"
	},
	
	FACTION.GOBLIN: {      #3
		FACTION.PLAYER: "hostile",
		FACTION.HUMAN: "hostile",
		FACTION.DEMON: "friendly",
		FACTION.GOBLIN: "friendly"
	}
}

func get_alignment(faction_a: int, faction_b: int) -> String:
	if faction_relationships.has(faction_a) and faction_relationships[faction_a].has(faction_b):
		return faction_relationships[faction_a][faction_b]
	return "neutral"
