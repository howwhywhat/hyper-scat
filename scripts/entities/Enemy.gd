extends KinematicBody2D

export (NodePath) var PLAYER_SCENE
onready var player = get_node(PLAYER_SCENE)

# drops
var ENEMY_DROPS_SCENE = preload("res://scenes/EnemyItemDrop.tscn")

export (int) var MAX_SPEED = 15
export (int) var HEALTH = 100
var motion = Vector2.ZERO

# abstract method
func damage(value):
	pass

func spawn_drops(amount : int):
	for number in amount:
		var drop = ENEMY_DROPS_SCENE.instance()
		drop.global_position = global_position
		drop.player = player
		get_tree().current_scene.add_child(drop)
