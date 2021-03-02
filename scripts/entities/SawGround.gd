extends Area2D

const SEVERED_BODY = preload("res://scenes/entities/AssManSeveredBody.tscn")
onready var flashAnimation = $BlinkAnimation
onready var hitbox = $Hitbox

func _on_SawGround_body_entered(body):
	if body.is_in_group("Player") and !body.wentThroughSaw:
		body.wentThroughSaw = true
		body.apply_damage(100)
		body.visible = false
		body.environmentHitbox.disabled = true
		hitbox.disabled = true

		var severed = SEVERED_BODY.instance()
		severed.global_position = global_position

		get_tree().current_scene.add_child(severed)

		if !body.left_arm_attached:
			severed.sprite.set_frame(2)
		if !body.right_arm_attached:
			severed.sprite.set_frame(1)
	elif body.is_in_group("ForeignEntities"):
		body.damage(2)
