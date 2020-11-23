extends StateMachine

onready var dust_particles = preload("res://scenes/particles/DustParticleEffect.tscn")

func _ready():
	add_state("idle")
	add_state("walk")
	add_state("jump")
	add_state("fall")
	add_state("special_attack")
	call_deferred("set_state", states.idle)

func _state_logic(delta):
	parent.loop_damage_checker()
	parent.apply_movement(delta)
	parent.apply_gravity(delta)
	parent.apply_jumping()
	parent.apply_special_attack_controls()

func _get_transition(delta):
	match state:
		states.idle:
			parent.state.text = "idle"
			if !parent.is_on_floor():
				if parent.motion.y < 0:
					return states.jump
				elif parent.motion.y > 0:
					return states.fall
			elif parent.x_input != 0:
				return states.walk
			elif parent.power_value != 0:
				return states.special_attack
		states.walk:
			parent.state.text = "walk"
			if !parent.is_on_floor():
				if parent.motion.y < 0:
					return states.jump
				elif parent.motion.y > 0:
					return states.fall
			elif parent.x_input == 0:
				return states.idle
		states.jump:
			parent.state.text = "jump"
			if parent.is_on_floor():
				return states.idle
			elif parent.motion.y >= 0:
				return states.fall
		states.fall:
			parent.state.text = "fall"
			if parent.is_on_floor():
				get_parent().get_node("Camera").add_trauma(0.2)
				get_parent().get_node("Camera").add_trauma(0.2)
				return states.idle
			elif parent.motion.y < 0:
				return states.jump
		states.special_attack:
			parent.state.text = "special attack"
			if !parent.is_on_floor():
				if parent.motion.y < 0:
					parent.power_value = 0
					return states.jump
				elif parent.motion.y > 0:
					parent.power_value = 0
					return states.fall
			elif parent.x_input != 0:
				parent.power_value = 0
				return states.walk
			elif parent.power_value == 0:
				return states.idle

	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.animation.play("idle")
		states.walk:
			parent.animation.play("walk")
		states.jump:
			if get_parent().x_input != 0:
				var dustParticles = dust_particles.instance()
				dustParticles.position = get_parent().position
				dustParticles.position.y += 11
				get_tree().current_scene.add_child(dustParticles)
				dustParticles.emitting = true
				dustParticles.get_process_material().initial_velocity = get_parent().x_input * 32
			parent.animation.play("jump")
		states.fall:
			parent.animation.play("fall")
		states.special_attack:
			parent.animation.play("special_attack")

func _exit_state(old_state, new_state):
	pass
