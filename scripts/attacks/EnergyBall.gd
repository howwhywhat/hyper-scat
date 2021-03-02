extends "res://scripts/attacks/Bullet.gd"

onready var flashAnimation = $BlinkAnimation
var IMPACT_SCENE = preload("res://scenes/particles/BulletImpact.tscn")

func _on_IfVisible_screen_exited():
	queue_free()

func _on_EnergyBall_body_entered(body):
	if body.is_in_group("Player") and body.hurtbox.disabled == false:
		body.apply_damage(damage)
	var impact = IMPACT_SCENE.instance()
	impact.global_position = global_position
	impact.rotation = rotation
	get_tree().current_scene.add_child(impact)
	queue_free()
