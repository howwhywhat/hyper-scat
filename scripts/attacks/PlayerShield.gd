extends StaticBody2D

onready var hurtbox : CollisionShape2D = $Hurtbox
onready var animation : AnimationPlayer = $Animation

func _on_Animation_animation_finished(anim_name : String) -> void:
	if anim_name == "spawn_in":
		animation.play("idle")
	elif anim_name == "remove":
		visible = false
		hurtbox.disabled = true
