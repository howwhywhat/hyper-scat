extends Enemy

# general functionality
onready var sleepingParticles = $SleepingParticles
onready var collider = $Collider
onready var animation = $Animation
onready var sprite = $Texture
onready var hurtbox = $BulletDetection/Hurtbox
onready var stateMachine = $StateMachine
var woke_up = false
var been_bounced = false

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

func _process(_delta):
	if can_see() and player != null:
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

func in_sight():
	var dir = Vector2(player.position.x - position.x, player.position.y - position.y)
	chaseHitbox.cast_to = dir
	if chaseHitbox.get_collider() != player:
		return false
	else:
		return true

func can_see():
	if not playerDetection == null:
		if playerDetection.overlaps_body(player):
			if in_sight():
				return true
		else:
			chaseHitbox.cast_to = Vector2.ZERO
			return false

func can_jump():
	if is_on_floor() and jumpBottom.is_colliding() or jumpTop.is_colliding():
		return true
	else:
		return false

func move_towards_player(delta):
	var direction = (player.global_position - global_position).normalized()
	motion = motion.move_toward(direction * MAX_SPEED, 25 * delta)

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
	elif anim_name == "death_2":
		instance_explosion_scene()
		queue_free()

func pounced(bouncer):
	damage(9999)
	bouncer.bounce()
