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
	call_deferred("set_state", states.asleep)

func _state_logic(delta):
	if state_logic_enabled == true:
		parent.move()
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
				if not parent.floorLeft.is_colliding() or parent.wallLeft.is_colliding():
					return states.right
				if parent.leftAttackDetection.is_colliding() or parent.rightAttackDetection.is_colliding():
					return states.mouth_attack
				for bodies in parent.playerChaseDetection.get_overlapping_bodies():
					if bodies.is_in_group("Player"):
						return states.chase
				if parent.HEALTH <= 0:
					return states.death
			else:
				return states.death
		states.right:
			if state_enabled:
				parent.stateLabel.text = "right"
				if not parent.floorRight.is_colliding() or parent.wallRight.is_colliding():
					return states.left
				if parent.rightAttackDetection.is_colliding() or parent.rightAttackDetection.is_colliding():
					return states.mouth_attack
				for bodies in parent.playerChaseDetection.get_overlapping_bodies():
					if bodies.is_in_group("Player"):
						return states.chase
				if parent.HEALTH <= 0:
					return states.death
			else:
				return states.death
		states.chase:
			if state_enabled:
				parent.stateLabel.text = "chase"
				if parent.position.distance_to(parent.player.position) < 35:
					return states.mouth_attack
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
			chase = false
			mouthAttack = MOUTH_ATTACK_SCENE.instance()
			mouthAttack.position = parent.mouthPosition.position
			get_parent().add_child(mouthAttack)
			parent.stop_movement()
			parent.animation.play("idle")
		states.asleep:
			chase = false
			parent.animation.play("asleep")
		states.wake_up:
			chase = false
			parent.animation.play("wake_up")
		states.left:
			chase = false
			parent.animation.play("walk")
			parent.motion.x = -parent.MAX_SPEED
			parent.sprite.flip_h = true
		states.right:
			chase = false
			parent.animation.play("walk")
			parent.motion.x = parent.MAX_SPEED
			parent.sprite.flip_h = false
		states.chase:
			chase = true
		states.death:
			state_enabled = false
			state_logic_enabled = false
			if parent.collider != null:
				parent.collider.queue_free()
			parent.stop_movement()
			if mouthAttack != null:
				mouthAttack.animation.play("mouth_close")
			parent.animation.play("death")

func _exit_state(old_state, new_state):
	pass
