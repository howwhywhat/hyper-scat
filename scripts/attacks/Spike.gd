extends Sprite

export (int) var damage = 0
onready var animation = $Animation
onready var flashAnimation = $BlinkAnimation

func _on_Animation_animation_finished(anim_name):
	if anim_name == "start":
		animation.play("static")
	elif anim_name == "lower":
		queue_free()

func _on_Timer_timeout():
	animation.play("lower")

func _on_PlayerDetection_body_entered(body):
	if body.is_in_group("Player"):
		body.lastHitEntity = self
		if body.stateMachine.state == body.stateMachine.states.fall:
			body.apply_damage(damage)
			body.bounce()
		elif body.stateMachine.state == body.stateMachine.states.jump:
			body.apply_damage(damage)
			body.bounce()
