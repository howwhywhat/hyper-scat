extends KinematicBody2D

class_name Enemy

export (NodePath) var PLAYER_SCENE
onready var player = get_node(PLAYER_SCENE)

# scenes
var EXPLOSION_SCENE = preload("res://scenes/particles/ExplosionSprite.tscn")
var BLOOD_SCENE = preload("res://scenes/particles/BloodShitParticles.tscn")
var ENEMY_DROPS_SCENE = preload("res://scenes/EnemyItemDrop.tscn")
var ALERT_SCENE = preload("res://scenes/AlarmScene.tscn")

export (int) var JUMP = 240
export (int) var MAX_SPEED = 15
export (int) var HEALTH = 100
var motion = Vector2.ZERO

# abstract method
func damage(value):
	pass

func move():
	motion = move_and_slide(motion, Vector2.UP)

func _apply_gravity(delta):
	motion.y += GlobalConstants.GRAVITY * delta
	motion.y += GlobalConstants.GRAVITY * delta

func jump():
	motion.y -= JUMP

func spawn_drops(amount : int):
	for number in amount:
		var drop = ENEMY_DROPS_SCENE.instance()
		drop.global_position = global_position
		drop.player = player
		get_tree().current_scene.add_child(drop)

func instance_explosion_scene():
	var explosion = EXPLOSION_SCENE.instance()
	explosion.global_position = global_position
	get_tree().current_scene.add_child(explosion)

func instance_alert_scene():
	var alertScene = ALERT_SCENE.instance()
	alertScene.global_position = global_position
	get_tree().current_scene.add_child(alertScene)

func stop_movement():
	motion = move_and_slide(Vector2.ZERO, Vector2.UP)

func instance_blood_particles():
	var blood = BLOOD_SCENE.instance()
	blood.global_position = global_position
	get_tree().current_scene.add_child(blood)
