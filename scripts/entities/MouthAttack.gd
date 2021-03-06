extends Area2D

onready var sprite : Sprite = $Sprite
onready var animation : AnimationPlayer = $Animation
var attack_completed : bool = false

export (int) var damage = 25.0

func _process(_delta) -> void:
	if get_parent().sprite.flip_h == true:
		sprite.flip_h = false
	else:
		sprite.flip_h = true

func _on_MouthAttack_body_entered(body) -> void:
	if body.is_in_group("PlayerShield"):
		return
	elif body.is_in_group("Player") and body.hurtbox.disabled == false:
		if body.health > 0:
			body.lastHitEntity = get_parent()
			body.apply_damage(damage)

func _on_Animation_animation_finished(anim_name : String) -> void:
	attack_completed = true
	get_parent().get_node("StateMachine").call_deferred("set_state", get_parent().get_node("StateMachine").states.left)
	queue_free()
