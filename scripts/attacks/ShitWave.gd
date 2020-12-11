extends Area2D

onready var animation = $Animations

export (int) var damage = 10.0

func _on_Animations_animation_finished(anim_name):
	if anim_name == "spawn_In":
		queue_free()

func _on_ShitWave_body_entered(body):
	if body.is_in_group("ForeignEntities"):
		body.damage(damage)
