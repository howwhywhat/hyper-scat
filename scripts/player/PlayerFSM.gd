extends StateMachine

onready var dust_particles = preload("res://scenes/particles/DustParticleEffect.tscn")

var state_logic_enabled = true

func _ready():
	add_state("idle")
	add_state("walk")
	add_state("wall_slide")
	add_state("jump")
	add_state("fall")
	add_state("special_attack")
	add_state("death")
	add_state("stunned")
	add_state("shoot")
	call_deferred("set_state", states.idle)

func _state_logic(delta):
	parent.apply_gravity(delta)
	if state_logic_enabled == true:
		parent.apply_movement(delta)
		parent.apply_special_attack_controls()
		parent.loop_damage_checker()
		parent.start_movement()
		parent.apply_jumping()
		
		if state == states.wall_slide:
			parent.wall_slide_drop_check(delta)
			parent.wall_slide_fast_slide_check(delta)
			parent.apply_wall_slide_jump(parent.get_wall_axis())
	else:
		parent.apply_empty_movement(delta)

func _get_transition(delta):
	match state:
		states.idle:
			parent.state.text = "idle"
			parent.sprite.scale.x = 1
			parent.halfAss.scale.x = 1
			if !parent.is_on_floor():
				if parent.motion.y < 0 and !parent.jumpBuffer.is_stopped():
					return states.jump
				elif parent.motion.y > 0 and parent.was_on_floor and parent.coyoteTimer.is_stopped():
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
				if parent.motion.y < 0 and !parent.jumpBuffer.is_stopped():
					return states.jump
				elif parent.motion.y > 0 and parent.was_on_floor and parent.coyoteTimer.is_stopped():
					return states.fall
			elif parent.x_input == 0:
				return states.idle
			if parent.health <= 0:
				return states.death
			if parent.stunned == true:
				return states.stunned
			if Input.is_action_pressed("shoot") and parent.can_fire_bullet == true:
				return states.shoot
			if not parent.is_on_floor() and parent.is_on_wall():
				return states.wall_slide
		states.jump:
			parent.state.text = "jump"
			if parent.is_on_floor():
				return states.idle
			elif parent.motion.y > 0 and parent.was_on_floor and parent.coyoteTimer.is_stopped():
				return states.fall
			if parent.stunned == true:
				return states.stunned
			if Input.is_action_pressed("shoot") and parent.can_fire_bullet == true:
				return states.shoot
			if not parent.is_on_floor() and parent.is_on_wall():
				return states.wall_slide
		states.fall:
			parent.state.text = "fall"
			if parent.is_on_floor():
				get_parent().get_node("Camera").add_trauma(0.2)
				get_parent().get_node("Camera").add_trauma(0.2)
				return states.idle
			elif parent.motion.y < 0 and !parent.jumpBuffer.is_stopped():
				return states.jump
			if parent.health <= 0:
				return states.death
			if parent.stunned == true:
				return states.stunned
			if Input.is_action_pressed("shoot") and parent.can_fire_bullet == true:
				return states.shoot
			if not parent.is_on_floor() and parent.is_on_wall():
				return states.wall_slide
		states.special_attack:
			parent.state.text = "special attack"
			if !parent.is_on_floor():
				if parent.motion.y < 0 and !parent.jumpBuffer.is_stopped():
					parent.power_value = 0
					return states.jump
				elif parent.motion.y > 0 and parent.was_on_floor and parent.coyoteTimer.is_stopped():
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
				if parent.motion.y < 0 and !parent.jumpBuffer.is_stopped():
					parent.power_value = 0
					return states.jump
				elif parent.motion.y > 0 and parent.was_on_floor and parent.coyoteTimer.is_stopped():
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
		states.wall_slide:
			parent.state.text = "wall_slide"
			if parent.get_wall_axis() == 0 or parent.is_on_floor():
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
			parent.jumpBuffer.stop()
			parent.animation.play("jump")
		states.fall:
			parent.coyoteTimer.start()
			parent.motion.y = 0
			parent.animation.play("fall")
		states.special_attack:
			parent.animation.play("special_attack")
		states.death:
			state_logic_enabled = false
			parent.animation.stop()
			parent.animation.play("death")
		states.stunned:
			parent.FRICTION = 0.1
			var direction = parent.transform.origin - parent.enemyOrigin
			direction.y = 0
			parent.apply_knockback(-direction)
			
			parent.animation.play("stunned")
			state_logic_enabled = false
			yield(get_tree().create_timer(1.25), "timeout")
			parent.FRICTION = 0.25
			state_logic_enabled = true
		states.shoot:
			parent.shoot()
		states.wall_slide:
			parent.animation.play("wall_slide")
			
			var wallAxis = parent.get_wall_axis()
			if wallAxis != 0:
				parent.sprite.scale.x = -wallAxis
				parent.halfAss.scale.x = -wallAxis

func _exit_state(old_state, new_state):
	pass
