extends "res://scripts/entities/Enemy.gd"

# general functionality
onready var collider = $Collider
onready var hurtbox = $PlayerDamage/Hurtbox
onready var animation = $Animation
onready var sprite = $Texture
onready var stateMachine = $StateMachine
var woke_up = false
var been_bounced = false
const GRAVITY = 200
const JUMP = 240

# raycasting / general ai
onready var floorLeft = $FloorLeft
onready var floorRight = $FloorRight
onready var wallLeft  = $WallLeft
onready var wallRight  = $WallRight
onready var mouthPosition = $MouthPosition

# player detection
onready var playerDetection = $PlayerDetectionWakeup
onready var leftAttackDetection = $LeftPlayerAttackDetection
onready var rightAttackDetection = $RightPlayerAttackDetection
onready var chaseHitbox = $PlayerChaseCast

# jumping variables
onready var jumpTop = $JumpTop
onready var jumpBottom = $JumpBottom

# debugging
onready var stateLabel = $Label

export (NodePath) var PLAYER_SCENE
onready var player = get_node(PLAYER_SCENE)

func _process(_delta):
	if player != null:
		if global_position.x < player.global_position.x:
			if stateMachine.mouthAttack != null:
				stateMachine.mouthAttack.position.x = mouthPosition.position.x
			sprite.flip_h = false
		else:
			if stateMachine.mouthAttack != null:
				stateMachine.mouthAttack.position.x = mouthPosition.position.x
			sprite.flip_h = true
	
	if sprite.flip_h == true:
		mouthPosition.position.x = -24
		jumpTop.cast_to = Vector2(-12, 0)
		jumpBottom.cast_to = Vector2(-12, 0)
	else:
		mouthPosition.position.x = 24
		jumpTop.cast_to = Vector2(12, 0)
		jumpBottom.cast_to = Vector2(12, 0)

func _apply_gravity(delta):
	motion.y += GRAVITY * delta
	motion.y += GRAVITY * delta

func in_sight():
	var dir = Vector2(player.position.x - position.x, player.position.y - position.y)
	chaseHitbox.cast_to = dir
	if chaseHitbox.get_collider() != player:
		return false
	else:
		return true

func can_see():
	if playerDetection.overlaps_body(player):
		if in_sight():
			return true
	else:
		chaseHitbox.cast_to = Vector2.ZERO
		return false

func jump():
	motion.y -= JUMP

func can_jump():
	if is_on_floor() and jumpBottom.is_colliding() or jumpTop.is_colliding():
		return true
	else:
		return false

func move_towards_player(delta):
	var direction = (player.global_position - global_position).normalized()
	motion = motion.move_toward(direction * MAX_SPEED, 25 * delta)

func stop_movement():
	motion = move_and_slide(Vector2.ZERO, Vector2.UP)

func move():
	motion.y += 5
	motion = move_and_slide(motion, Vector2.UP)

func damage(value):
	HEALTH -= value

func _on_Animation_animation_finished(anim_name):
	if anim_name == "wake_up":
		woke_up = true
	elif anim_name == "death":
		queue_free()

func pounced(bouncer):
	damage(9999)
	bouncer.bounce()
