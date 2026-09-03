extends Node
class_name EnemyState
@export var enemy: Enemy

var vision
var player: CharacterBody2D
var entity: CharacterBody2D
var take_dmg
var hitbox
var anims: AnimationPlayer
var stats

signal Transitioned

func Enter():
	pass

func Exit():
	pass

func Update(_delta: float):
	pass

func Physics_Update(_delta: float):
	pass
