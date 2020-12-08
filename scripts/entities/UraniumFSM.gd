extends StateMachine

var state_logic_enabled = true
var state_enabled = true
var chase = true

func _ready():
	add_state("idle")
	add_state("asleep")
	add_state("wake_up")
	add_state("stunned")
	add_state("death")
	call_deferred("set_state", states.asleep)

func _state_logic(delta):
	if state_logic_enabled:
		parent.move()

func _get_transition(delta):
	match state:
		states.asleep:
			if state_enabled:
				parent.state.text = "asleep"
				for bodies in parent.playerDetection.get_overlapping_bodies():
					if bodies.is_in_group("Player"):
						return states.wake_up
				if parent.HEALTH <= 0:
					return states.death
			else:
				return states.death
		states.wake_up:
			if state_enabled:
				parent.state.text = "wake_up"
				if parent.playerDetection.get_overlapping_bodies().size() == 0:
					return states.asleep
				else:
					return states.idle
				if parent.HEALTH <= 0:
					return states.death
			else:
				return states.death
		states.idle:
			if state_enabled:
				parent.state.text = "idle"
				if parent.stunned == true:
					return states.stunned
			else:
				return states.death
		states.stunned:
			if state_enabled:
				parent.state.text = "stunned"
				if parent.stunned == false:
					return states.idle
				if parent.HEALTH <= 0:
					return states.death
			else:
				return states.death
		states.death:
			parent.state.text = "death"
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.asleep:
			parent.sleepingParticles.emitting = true
			chase = false
			parent.animation.play("idle")
		states.wake_up:
			parent.instance_alert_scene()
			parent.sleepingParticles.emitting = true
			chase = false
			parent.animation.play("idle")
		states.idle:
			parent.sleepingParticles.emitting = true
			chase = false
			parent.animation.play("idle")
		states.stunned:
			parent.sleepingParticles.emitting = false
			chase = false
			parent.stop_movement()
			parent.instance_blood_particles()
			parent.flashAnimation.play("flash")
			if parent.sprite.flip_h == true:
				parent.apply_knockback(Vector2(-45, 0))
			else:
				parent.apply_knockback(Vector2(45, 0))
			parent.animation.play("stunned")
		states.death:
			parent.sleepingParticles.emitting = false
			state_enabled = false
			state_logic_enabled = false
			parent.spawn_drops(3)
			parent.flashAnimation.play("flash")
			parent.animation.play("death")

func _exit_state(old_state, new_state):
	pass
