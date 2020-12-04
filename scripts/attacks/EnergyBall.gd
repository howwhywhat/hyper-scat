extends "res://scripts/attacks/Bullet.gd"

func _on_IfVisible_screen_exited():
	queue_free()

func _on_EnergyBall_body_entered(body):
	if body.is_in_group("Player") and body.hurtbox.disabled == false:
		body.apply_damage(damage)
		queue_free()
	elif body.is_in_group("WallTiles"):
		sleeping = true
		queue_free()
	else:
		queue_free()
