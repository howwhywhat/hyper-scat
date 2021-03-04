extends Enemy

# general functionality
onready var sleepingParticles := $SleepingParticles
onready var collider := $Collider
onready var animation : AnimationPlayer = $Animation
onready var flashAnimation : AnimationPlayer = $BlinkAnimation
onready var sprite : Sprite = $Texture
onready var hurtbox := $BulletDetection/Hurtbox
onready var stateMachine : StateMachine = $StateMachine
onready var patrolTimer : Timer = $PatrolTimer
var woke_up : bool = false
var been_bounced : bool = false
var can_flip_h : bool = true
var patrolling : bool = false
var player_last_seen = null

# corpse
const CORPSE_SCENE = preload("res://scenes/entities/PieceOfShitSeparated.tscn")
onready var positionsForCorpse := $PositionsForCorpse

# raycasting / general ai
onready var floorLeft := $FloorLeft
onready var floorRight := $FloorRight
onready var wallLeft := $WallLeft
onready var wallRight := $WallRight
onready var topRight := $TopRight
onready var topLeft := $TopLeft
onready var mouthPosition := $MouthPosition

# player detection
onready var playerDetection := $PlayerDetectionWakeup
onready var leftAttackDetection := $LeftPlayerAttackDetection
onready var rightAttackDetection := $RightPlayerAttackDetection
onready var chaseHitbox := $PlayerChaseCast

# jumping variables
onready var jumpTop := $JumpTop
onready var jumpBottom = $JumpBottom

# debugging
onready var stateLabel : Label = $Label

# death shoot
var number_of_shots : int = 12
const BULLET_SCENE := preload("res://scenes/attacks/DeathBall.tscn")
onready var pivot := $Pivot
onready var bulletPosition := $Pivot/BulletPosition

func _process(_delta) -> void:
	if can_see() and player != null and can_flip_h:
		if global_position.x < player.global_position.x:
			if stateMachine.mouthAttack != null:
				stateMachine.mouthAttack.position.x = mouthPosition.position.x
			sprite.flip_h = false
		else:
			if stateMachine.mouthAttack != null:
				stateMachine.mouthAttack.position.x = mouthPosition.position.x
			sprite.flip_h = true
	
	if sprite.flip_h and can_flip_h:
		mouthPosition.position.x = -24
		jumpTop.cast_to = Vector2(-12, 0)
		jumpBottom.cast_to = Vector2(-12, 0)
	else:
		mouthPosition.position.x = 24
		jumpTop.cast_to = Vector2(12, 0)
		jumpBottom.cast_to = Vector2(12, 0)

func in_sight():
	var dir := Vector2(player.position.x - position.x , player.position.y - position.y)
	chaseHitbox.cast_to = dir
	if chaseHitbox.get_collider() != player:
		return false
	else:
		return true

func can_see():
	if not playerDetection == null:
		if playerDetection.overlaps_body(player):
			if in_sight():
				player_last_seen = player.global_position
				patrolTimer.start()
				patrolling = true
				return true
		else:
			chaseHitbox.cast_to = Vector2.ZERO
			return false

func can_jump():
	if is_on_floor() and jumpBottom.is_colliding() or jumpTop.is_colliding():
		return true
	else:
		return false

func move_towards_player(delta : float) -> void:
	var direction = (player.global_position - global_position).normalized()
	motion = motion.move_toward(direction * MAX_SPEED, 25 * delta)

func move_towards_last_seen(delta : float) -> void:
	var direction = (player_last_seen - global_position).normalized()
	motion = motion.move_toward(direction * MAX_SPEED, 25 * delta)

func move() -> void:
	motion = move_and_slide(motion, Vector2.UP)

func damage(value : float) -> void:
	player.get_node("Camera").add_trauma(0.3)
	HEALTH -= value

func shoot() -> void:
	player.lastHitEntity = self
	for shot in number_of_shots:
		var bullet = BULLET_SCENE.instance()
		pivot.rotation += (2 * PI / number_of_shots)
		bullet.global_position = bulletPosition.global_position
		bullet.rotation = pivot.rotation
		get_tree().current_scene.add_child(bullet)
		yield(get_tree().create_timer(.002), "timeout")

func spawn_corpse() -> void:
	for x in range(0, 3):
		randomize()
		var randomAngles := [180, -180, 90, -90, 270, -270, -40, 40, 45, -45]
		var finalChoice = randomAngles[randi() % randomAngles.size()]

		var corpse := CORPSE_SCENE.instance()
		corpse.global_position = positionsForCorpse.get_node("Middle").global_position
		corpse.rotation = finalChoice
		get_tree().current_scene.add_child(corpse)

func _on_Animation_animation_finished(anim_name : String) -> void:
	if anim_name == "wake_up":
		woke_up = true
	elif anim_name == "death":
		visible = false
		yield(get_tree().create_timer(2), "timeout")
		queue_free()
	elif anim_name == "death_2":
		instance_explosion_scene()
		visible = false
		yield(get_tree().create_timer(2), "timeout")
		queue_free()

func pounced(bouncer) -> void:
	damage(9999)
	bouncer.bounce()

func _on_PatrolTimer_timeout() -> void:
	patrolling = false
