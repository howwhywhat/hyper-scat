extends "res://scripts/attacks/Bullet.gd"

var IMPACT_SCENE = preload("res://scenes/particles/BulletImpact.tscn")

func _on_ShitBall_body_entered(body):
	if body.is_in_group("ForeignEntities") and body.hurtbox.disabled == false:
		body.damage(damage)
	var impact = IMPACT_SCENE.instance()
	impact.global_position = global_position
	impact.rotation = rotation
	get_tree().current_scene.add_child(impact)
	queue_free()

func _on_IfVisible_screen_exited():
	queue_free()

func _on_Animation_animation_finished(anim_name):
	if anim_name == "fall_in":
		queue_free()
