extends Area2D

onready var sprite = $Sprite
onready var animation = $Animation
var attack_completed = false

export (int) var damage = 10.0

func _process(_delta):
	if get_parent().sprite.flip_h == true:
		sprite.flip_h = false
	else:
		sprite.flip_h = true

func _on_MouthAttack_body_entered(body):
	if body.is_in_group("Player") and body.hurtbox.disabled == false:
		if body.health > 0:
			body.apply_damage(damage)

func _on_Animation_animation_finished(anim_name):
	attack_completed = true
	get_parent().get_node("StateMachine").call_deferred("set_state", get_parent().get_node("StateMachine").states.left)
	queue_free()
