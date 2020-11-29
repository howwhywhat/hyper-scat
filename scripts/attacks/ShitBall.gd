extends "res://scripts/attacks/Bullet.gd"

func _on_ShitBall_body_entered(body):
	if body.is_in_group("ForeignEntities") and body.hurtbox.disabled == false:
		body.damage(damage)
		queue_free()
	elif body.is_in_group("WallTiles"):
		sleeping = true
		$Animation.play("fall_in")
	else:
		queue_free()

func _on_IfVisible_screen_exited():
	queue_free()

func _on_Animation_animation_finished(anim_name):
	if anim_name == "fall_in":
		queue_free()
