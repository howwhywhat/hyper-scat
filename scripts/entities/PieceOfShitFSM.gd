extends StateMachine

onready var MOUTH_ATTACK_SCENE = preload("res://scenes/entities/MouthAttack.tscn")
var mouthAttack
var chase = false

var state_enabled = true
var state_logic_enabled = true

func _ready():
	add_state("death")
	add_state("mouth_attack")
	add_state("chase")
	add_state("asleep")
	add_state("wake_up")
	add_state("left")
	add_state("right")
	add_state("jump")
	add_state("fall")
	call_deferred("set_state", states.asleep)

func _state_logic(delta):
	if state_logic_enabled == true:
		parent.move()
		parent._apply_gravity(delta)
		if chase == true:
			parent.move_towards_player(delta)

func _get_transition(delta):
	match state:
		states.asleep:
			if state_enabled:
				parent.stateLabel.text = "asleep"
				for bodies in parent.playerDetection.get_overlapping_bodies():
					if bodies.is_in_group("Player"):
						return states.wake_up
			else:
				return states.death
		states.wake_up:
			if state_enabled:
				parent.stateLabel.text = "woke_up"
				if parent.woke_up == true:
					return states.left
			else:
				return states.death
		states.left:
			if state_enabled:
				parent.stateLabel.text = "left"
				if parent.is_on_floor():
					if not parent.floorLeft.is_colliding() or parent.wallLeft.is_colliding():
						return states.right
					if parent.can_see() and parent.leftAttackDetection.is_colliding() or parent.rightAttackDetection.is_colliding():
						return states.mouth_attack
					if parent.can_see():
						return states.chase
				if parent.can_jump():
					return states.jump
				if parent.HEALTH <= 0:
					return states.death
			else:
				return states.death
		states.right:
			if state_enabled:
				parent.stateLabel.text = "right"
				if parent.is_on_floor():
					if not parent.floorRight.is_colliding() or parent.wallRight.is_colliding():
						return states.left
					if parent.can_see() and parent.rightAttackDetection.is_colliding() or parent.rightAttackDetection.is_colliding():
						return states.mouth_attack
					if parent.can_see():
						return states.chase
				if parent.can_jump():
					return states.jump
				if parent.HEALTH <= 0:
					return states.death
			else:
				return states.death
		states.chase:
			if state_enabled:
				parent.stateLabel.text = "chase"
				if parent.is_on_floor():
					if not parent.in_sight():
						return states.left
					if parent.can_see() and parent.position.distance_to(parent.player.position) < 35:
						return states.mouth_attack
				if parent.can_jump():
					return states.jump
				if parent.HEALTH <= 0:
					return states.death
			else:
				return states.death
		states.jump:
			if state_enabled:
				parent.stateLabel.text = "jump"
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
				if parent.is_on_floor():
					return states.left
				elif parent.motion.y < 0:
					return states.jump
				if parent.HEALTH <= 0:
					return states.death
			else:
				return states.death
		states.mouth_attack:
			if state_enabled:
				parent.stateLabel.text = "mouth_attack"
				if parent.HEALTH <= 0:
					return states.death
			else:
				return states.death
		states.death:
			parent.stateLabel.text = "death"
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.mouth_attack:
			parent.sleepingParticles.emitting = false
			chase = false
			mouthAttack = MOUTH_ATTACK_SCENE.instance()
			mouthAttack.position = parent.mouthPosition.position
			get_parent().add_child(mouthAttack)
			parent.stop_movement()
			parent.animation.play("idle")
		states.jump:
			parent.sleepingParticles.emitting = false
			chase = false
			parent.jump()
			parent.animation.play("idle")
		states.fall:
			parent.sleepingParticles.emitting = false
			chase = false
			parent.motion.y = 0
			parent.animation.play("fall")
		states.asleep:
			parent.sleepingParticles.emitting = true
			chase = false
			parent.animation.play("asleep")
		states.wake_up:
			parent.sleepingParticles.emitting = false
			chase = false
			parent.animation.play("wake_up")
		states.left:
			parent.sleepingParticles.emitting = false
			chase = false
			parent.animation.play("walk")
			parent.motion.x = -parent.MAX_SPEED
			parent.sprite.flip_h = true
		states.right:
			parent.sleepingParticles.emitting = false
			chase = false
			parent.animation.play("walk")
			parent.motion.x = parent.MAX_SPEED
			parent.sprite.flip_h = false
		states.chase:
			parent.sleepingParticles.emitting = false
			chase = true
		states.death:
			parent.instance_blood_particles()
			parent.sleepingParticles.emitting = false
			state_enabled = false
			state_logic_enabled = false
			if parent.collider != null:
				parent.collider.queue_free()
			if parent.leftAttackDetection != null:
				parent.leftAttackDetection.queue_free()
			if parent.rightAttackDetection != null:
				parent.rightAttackDetection.queue_free()
			if parent.chaseHitbox != null:
				parent.chaseHitbox.queue_free()
			if parent.playerDetection != null:
				parent.playerDetection.queue_free()
			parent.stop_movement()
			parent.spawn_drops(2)
			if mouthAttack != null:
				mouthAttack.animation.play("mouth_close")
			if parent.floorLeft.is_colliding() or parent.floorRight.is_colliding():
				randomize()
				var choices = ["death", "death_2"]
				var finalChoice = choices[randi() % choices.size()]
				parent.animation.play(finalChoice)
			else:
				parent.animation.play("death_2")

func _exit_state(old_state, new_state):
	pass
