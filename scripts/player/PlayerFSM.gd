extends StateMachine

onready var dust_particles = preload("res://scenes/particles/DustParticleEffect.tscn")

var state_logic_enabled = true

func _ready():
	add_state("idle")
	add_state("walk")
	add_state("jump")
	add_state("fall")
	add_state("special_attack")
	add_state("death")
	add_state("stunned")
	add_state("shoot")
	call_deferred("set_state", states.idle)

func _state_logic(delta):
	if state_logic_enabled == true:
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
			if parent.health <= 0:
				return states.death
			if parent.stunned == true:
				return states.stunned
			if Input.is_action_pressed("shoot") and parent.can_fire_bullet == true:
				return states.shoot
		states.walk:
			parent.state.text = "walk"
			if !parent.is_on_floor():
				if parent.motion.y < 0:
					return states.jump
				elif parent.motion.y > 0:
					return states.fall
			elif parent.x_input == 0:
				return states.idle
			if parent.health <= 0:
				return states.death
			if parent.stunned == true:
				return states.stunned
			if Input.is_action_pressed("shoot") and parent.can_fire_bullet == true:
				return states.shoot
		states.jump:
			parent.state.text = "jump"
			if parent.is_on_floor():
				return states.idle
			elif parent.motion.y >= 0:
				return states.fall
			if parent.stunned == true:
				return states.stunned
			if Input.is_action_pressed("shoot") and parent.can_fire_bullet == true:
				return states.shoot
		states.fall:
			parent.state.text = "fall"
			if parent.is_on_floor():
				get_parent().get_node("Camera").add_trauma(0.2)
				get_parent().get_node("Camera").add_trauma(0.2)
				return states.idle
			elif parent.motion.y < 0:
				return states.jump
			if parent.health <= 0:
				return states.death
			if parent.stunned == true:
				return states.stunned
			if Input.is_action_pressed("shoot") and parent.can_fire_bullet == true:
				return states.shoot
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
			if parent.health <= 0:
				return states.death
			if parent.stunned == true:
				return states.stunned
			if Input.is_action_pressed("shoot") and parent.can_fire_bullet == true:
				return states.shoot
		states.death:
			parent.state.text = "death"
		states.stunned:
			parent.state.text = "stunned"
			if parent.stunned == false:
				return states.idle
		states.shoot:
			parent.state.text = "shoot"
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
			elif parent.power_value != 0:
				return states.special_attack
			if parent.health <= 0:
				return states.death
			if parent.stunned == true:
				return states.stunned
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
		states.death:
			state_logic_enabled = false
			parent.animation.play("death")
		states.stunned:
			parent.animation.play("stunned")
			state_logic_enabled = false
			yield(get_tree().create_timer(1.25), "timeout")
			state_logic_enabled = true
		states.shoot:
			parent.shoot()

func _exit_state(old_state, new_state):
	pass
