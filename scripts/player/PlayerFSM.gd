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
	add_state("block")
	call_deferred("set_state", states.idle)

func _state_logic(delta):
	parent.apply_gravity(delta)
	parent.start_movement()
	if state_logic_enabled == true:
		parent.apply_movement(delta)
		parent.apply_special_attack_controls()
#		parent.loop_damage_checker()
		parent.apply_jumping()
		
		if state == states.wall_slide:
			parent.wall_slide_drop_check(delta)
			parent.wall_slide_fast_slide_check(delta)
			parent.apply_wall_slide_jump(parent.get_wall_axis())
	else:
		parent.motion.x = lerp(parent.motion.x, 0, 0.25)

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
			if parent.power_value != 0:
				return states.special_attack
			if parent.health <= 0:
				return states.death
			if parent.stunned == true:
				return states.stunned
			if Input.is_action_pressed("shoot") and parent.can_fire_bullet == true:
				return states.shoot
			if Input.is_action_pressed("block") and parent.shieldTimer.is_stopped() and parent.x_input == 0:
				return states.block
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
			elif parent.motion.y > 0 and !parent.is_on_floor() and parent.was_on_floor and parent.coyoteTimer.is_stopped():
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
					return states.jump
				elif parent.motion.y > 0 and parent.was_on_floor and parent.coyoteTimer.is_stopped():
					return states.fall
			elif parent.x_input != 0:
				return states.walk
			if parent.power_value == 0:
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
					return states.jump
				elif parent.motion.y > 0 and parent.was_on_floor and parent.coyoteTimer.is_stopped():
					return states.fall
			elif parent.x_input != 0:
				return states.walk
			elif parent.x_input == 0:
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
		states.block:
			parent.state.text = "block"
			if !parent.is_on_floor():
				if parent.motion.y < 0 and !parent.jumpBuffer.is_stopped():
					return states.jump
				elif parent.motion.y > 0 and parent.was_on_floor and parent.coyoteTimer.is_stopped():
					return states.fall
			elif parent.x_input != 0:
				return states.walk
			elif parent.x_input == 0 and not Input.is_action_pressed("block"):
				return states.idle
			if parent.power_value != 0:
				return states.special_attack
			if parent.health <= 0:
				return states.death
			if parent.stunned == true:
				return states.stunned
			if Input.is_action_pressed("shoot") and parent.can_fire_bullet == true:
				return states.shoot
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.shield.animation.play("remove")
			parent.animation.stop()
			parent.animation.play("idle")
			# just sets the boolean to true for dashing because i'm too lazy to add dash state in this cursed fsm
			parent.able_to_dash = true
			parent.power_value = 0
		states.walk:
			parent.shield.animation.play("remove")
			parent.power_value = 0
			parent.able_to_dash = true
			parent.animation.play("walk")
		states.jump:
			parent.shield.animation.play("remove")
			parent.power_value = 0
			parent.able_to_dash = true
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
			parent.shield.animation.play("remove")
			parent.able_to_dash = false
			parent.power_value = 0
			parent.coyoteTimer.start()
			parent.motion.y = 0
			parent.animation.play("fall")
		states.special_attack:
			parent.shield.animation.play("remove")
			parent.able_to_dash = false
			parent.animation.play("special_attack")
		states.death:
			parent.shield.animation.play("remove")
			state_logic_enabled = false # WHY THE FUCK ISN'T THIS WORKING????!!!!
			parent.able_to_dash = false
			if parent.bloodParticlesLeft != null:
				parent.bloodParticlesLeft.emitting = false
			if parent.bloodParticlesRight != null:
				parent.bloodParticlesRight.emitting = false
			parent.power_value = 0
			parent.animation.stop()
			parent.animation.play("death")
		states.stunned:
			parent.shield.animation.play("remove")
			parent.able_to_dash = false
			parent.power_value = 0
			var direction = parent.transform.origin - parent.enemyOrigin
			direction.y /= 4
			# WHY THE FUCK IS IT NULL I DON'T KNOW BUT I HAVE TO ADD THIS STUPID FUCKING CHECK SO IT DOESN'T CRASH FUCK THIS
			if parent.lastHitEntity != null:
				parent.lastHitEntity.flashAnimation.play("damager")
				if parent.lastHitEntity.global_position < parent.global_position:
					parent.apply_knockback(direction)
				else:
					parent.apply_knockback(-direction)
			parent.animation.play("stunned")
			parent.flashAnimation.play("flash")
		states.shoot:
			parent.shield.animation.play("remove")
			parent.able_to_dash = false
			parent.power_value = 0
			parent.shoot()
		states.wall_slide:
			parent.shield.animation.play("remove")
			parent.able_to_dash = false
			parent.power_value = 0
			parent.animation.play("wall_slide")
			
			var wallAxis = parent.get_wall_axis()
			if wallAxis != 0:
				if parent.sprite.flip_h == false:
					parent.sprite.scale.x = wallAxis
					parent.halfAss.scale.x = wallAxis
				else:
					parent.sprite.scale.x = -wallAxis
					parent.halfAss.scale.x = -wallAxis
		states.block:
			parent.able_to_dash = false
			parent.power_value = 0
			parent.shield.visible = true
			parent.shield.animation.play("spawn_in")
			parent.shieldTimer.start()
			parent.shieldHurtbox.disabled = false
			parent.animation.play("block")

func _exit_state(old_state, new_state):
	pass
