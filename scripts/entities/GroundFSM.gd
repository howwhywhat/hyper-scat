extends StateMachine

var state_enabled = true
var state_logic_enabled = true

func _ready():
	add_state("asleep")
	add_state("wake_up")
	add_state("idle")
	add_state("death")
	call_deferred("set_state", states.asleep)

func _state_logic(delta):
	if state_logic_enabled == true:
		parent._apply_gravity(delta)
		parent.shoot()

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
				if parent.wake_up_animation_completed == true:
					return states.idle
				if parent.HEALTH <= 0:
					return states.death
			else:
				return states.death
		states.idle:
			if state_enabled:
				parent.state.text = "idle"
				if parent.playerDetection.get_overlapping_bodies().size() == 0:
					return states.asleep
				if parent.HEALTH <= 0:
					return states.death
		states.death:
			parent.state.text = "death"
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.asleep:
			parent.sleepingParticles.emitting = true
			parent.weaponAnimation.play("asleep")
		states.idle:
			parent.animation.play("idle")
			parent.weaponAnimation.play("idle")
		states.wake_up:
			parent.sleepingParticles.emitting = false
			parent.animation.play("idle")
			parent.weaponAnimation.play("wake_up")
		states.death:
			state_enabled = false
			parent.weaponAnimation.play("asleep")

func _exit_state(old_state, new_state):
	pass
