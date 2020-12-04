extends StateMachine

onready var dust_particles = preload("res://scenes/particles/DustParticleEffect.tscn")

var state_enabled = true
var state_logic_enabled = true
var chase = true

func _ready():
	add_state("idle")
	add_state("stunned")
	add_state("attack")
	add_state("death")
	add_state("chase")
	add_state("left")
	add_state("right")
	add_state("jump")
	add_state("fall")
	call_deferred("set_state", states.idle)

func _state_logic(delta):
	if state_logic_enabled == true:
		parent._apply_gravity(delta)
		parent.move()
		if chase == true:
			parent.move_towards_player(delta)

func _get_transition(delta):
	match state:
		states.idle:
			if state_enabled:
				parent.state.text = "idle"
				for bodies in parent.playerDetection.get_overlapping_bodies():
					if bodies.is_in_group("Player"):
						return states.left
				if parent.stunned == true:
					return states.stunned
			else:
				return states.death
		states.left:
			if state_enabled:
				parent.state.text = "left"
				if parent.is_on_floor():
					if not parent.floorLeft.is_colliding() or parent.wallLeft.is_colliding():
						return states.right
					if parent.can_see() and parent.leftAttackDetection.is_colliding() or parent.rightAttackDetection.is_colliding():
						return states.attack
					if parent.can_see():
						return states.chase
				if parent.can_jump():
					return states.jump
				if parent.HEALTH <= 0:
					return states.death
				if parent.stunned == true:
					return states.stunned
			else:
				return states.death
		states.right:
			if state_enabled:
				parent.state.text = "right"
				if parent.is_on_floor():
					if not parent.floorRight.is_colliding() or parent.wallRight.is_colliding():
						return states.left
					if parent.can_see() and parent.rightAttackDetection.is_colliding() or parent.rightAttackDetection.is_colliding():
						return states.attack
					if parent.can_see():
						return states.chase
				if parent.can_jump():
					return states.jump
				if parent.HEALTH <= 0:
					return states.death
				if parent.stunned == true:
					return states.stunned
			else:
				return states.death
		states.chase:
			if state_enabled:
				parent.state.text = "chase"
				if parent.is_on_floor():
					if not parent.in_sight():
						return states.left
					if parent.can_see() and parent.position.distance_to(parent.player.position) < 35:
						return states.attack
				if parent.can_jump():
					return states.jump
				if parent.HEALTH <= 0:
					return states.death
				if parent.stunned == true:
					return states.stunned
			else:
				return states.death
		states.attack:
			if state_enabled:
				parent.state.text = "attack"
				if parent.is_on_floor():
					if parent.animation.current_animation != "attack":
						return states.left
				if parent.can_jump():
					return states.jump
				if parent.HEALTH <= 0:
					return states.death
				if parent.stunned == true:
					return states.stunned
			else:
				return states.death
		states.stunned:
			if state_enabled:
				parent.state.text = "stunned"
				if parent.is_on_floor():
					if parent.stunned == false:
						return states.left
				if parent.HEALTH <= 0:
					return states.death
			else:
				return states.death
		states.death:
			parent.state.text = "death"
		states.jump:
			if state_enabled:
				parent.state.text = "jump"
				if parent.is_on_floor():
					return states.left
				elif parent.motion.y > 0:
					return states.fall
				if parent.HEALTH <= 0:
					return states.death
			else:
				return states.death
		states.fall:
			if state_enabled:
				parent.state.text = "fall"
				if parent.is_on_floor():
					return states.left
				elif parent.motion.y < 0:
					return states.jump
				if parent.HEALTH <= 0:
					return states.death
			else:
				return states.death
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.sleepingParticles.emitting = true
			chase = false
			parent.animation.play("idle")
		states.stunned:
			parent.sleepingParticles.emitting = false
			chase = false
			parent.stop_movement()
			parent.instance_blood_particles()
			parent.stunned_vfx()
			if parent.sprite.flip_h == true:
				parent.apply_knockback(Vector2(-45, 0))
			else:
				parent.apply_knockback(Vector2(45, 0))
			parent.animation.play("stunned")
		states.attack:
			parent.sleepingParticles.emitting = false
			chase = false
			parent.stop_movement()
			parent.animation.play("attack")
		states.left:
			parent.sleepingParticles.emitting = false
			chase = false
			parent.animation.play("walk")
			parent.motion.x = -parent.MAX_SPEED
			parent.sprite.flip_h = false
		states.right:
			parent.sleepingParticles.emitting = false
			chase = false
			parent.animation.play("walk")
			parent.motion.x = parent.MAX_SPEED
			parent.sprite.flip_h = true
		states.chase:
			parent.sleepingParticles.emitting = false
			chase = true
			parent.animation.play("walk")
		states.jump:
			parent.sleepingParticles.emitting = false
			chase = false
			parent.jump()
			parent.animation.play("walk")
		states.fall:
			parent.sleepingParticles.emitting = false
			chase = false
			parent.motion.y = 0
			parent.animation.play("fall")
		states.death:
			parent.sleepingParticles.emitting = false
			state_enabled = false
			state_logic_enabled = false
			if parent.collider != null:
				parent.collider.queue_free()
			if parent.floorLeft != null:
				parent.floorLeft.queue_free()
			if parent.floorRight != null:
				parent.floorRight.queue_free()
			if parent.wallRight != null:
				parent.wallRight.queue_free()
			if parent.wallLeft != null:
				parent.wallLeft.queue_free()
			if parent.leftAttackDetection != null:
				parent.leftAttackDetection.queue_free()
			if parent.rightAttackDetection != null:
				parent.rightAttackDetection.queue_free()
			if parent.chaseHitbox != null:
				parent.chaseHitbox.queue_free()
			if parent.playerDetection != null:
				parent.playerDetection.queue_free()
			if parent.hurtbox != null:
				parent.hurtbox.queue_free()
			parent.stop_movement()
			parent.spawn_drops(3)
			parent.stunned_vfx()
			parent.animation.play("death")

func _exit_state(old_state, new_state):
	pass
