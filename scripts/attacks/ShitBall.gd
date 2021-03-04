extends "res://scripts/attacks/Bullet.gd"

func _on_ShitBall_body_entered(body) -> void:
	if body.is_in_group("ForeignEntities") and body.hurtbox.disabled == false:
		body.damage(damage)
	queue_free()

func _on_IfVisible_screen_exited() -> void:
	queue_free()

func _on_Animation_animation_finished(anim_name : String) -> void:
	if anim_name == "fall_in":
		queue_free()
