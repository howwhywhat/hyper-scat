extends StaticBody2D

onready var hurtbox = $Hurtbox
onready var animation = $Animation

func _on_Animation_animation_finished(anim_name):
	if anim_name == "spawn_in":
		animation.play("idle")
	elif anim_name == "remove":
		visible = false
		hurtbox.disabled = true
