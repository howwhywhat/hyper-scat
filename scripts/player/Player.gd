extends KinematicBody2D

# general
var health : float = 100
var laxatives : int = 0
var stunned : bool = false
const DEATH_ID_SCENE := preload("res://scenes/interface/DeathUI.tscn")
const SHOOTING_PARTICLES := preload("res://scenes/particles/ShootingParticles.tscn")
var enemyOrigin : Vector2 = Vector2.ZERO
var lastHitEntity
var wentThroughSaw : bool = false
var enableBlood : bool = true
var unlocking : bool = false

export (PackedScene) var BLOOD_SCENE : PackedScene

# bullet type/weaponry
export (PackedScene) var bullet_type : PackedScene
var can_fire_bullet : bool = true

# signals
signal player_damaged(damage)

# camera control
export (NodePath) var camera_in_level : NodePath

# movement
const ACCELERATION = 512
var MAX_SPEED : int = 96
var FRICTION : float = 0.25
const AIR_RESISTANCE = 0.02
const JUMP_FORCE = 128

var motion : Vector2 = Vector2.ZERO
var x_input = 0

# attacks
var power_value : int = 0
var can_fire : bool = true
const shit_wave := preload("res://scenes/attacks/ShitWave.tscn")

# variables
onready var shieldTimer : Timer = $BlockedTimer
onready var shield := $PlayerShield
onready var shieldHurtbox : CollisionShape2D = $PlayerShield/Hurtbox

onready var specialAttackPositionL := $SpecialAttackPositionL
onready var specialAttackPositionR := $SpecialAttackPositionR

onready var environmentHitbox : CollisionShape2D = $EnvironmentHitbox
onready var stunnedTimer := $StunnedTimer
onready var animation : AnimationPlayer = $Animation
onready var flashAnimation : AnimationPlayer = $BlinkAnimation
onready var state : Label = $State
onready var stateMachine : StateMachine = $StateMachine
onready var halfAss : Sprite = $HalfAss
onready var sprite : Sprite = $CharacterSprite
onready var camera : Camera2D = $Camera
onready var ifVisible : VisibilityNotifier2D = $IfVisible
onready var bulletPosition : Position2D = $BulletPosition
onready var shootParticlesPos : Position2D = $ShootingParticlesPosition
onready var bounceRaycasts : Node2D = $BounceRaycasts
onready var hurtbox : CollisionShape2D = $BulletDetection/BulletHitbox
onready var light : Light2D = $LightingEffects

export (NodePath) var UI_NODE : NodePath
onready var ui := get_node(UI_NODE)
onready var uiHearts := ui.get_node("Hearts")
onready var uiLaxatives := ui.get_node("Laxatives").get_node("Label")

# dashing
var tappedRight : int = 0
var tappedLeft : int = 0
var dash : bool = false
var dashingRight : bool = false
var dashingLeft : bool = false
onready var dragTimer : Timer = $DragTimer
var drag : bool = false
var able_to_dash : bool = false
const GHOST_SPRITE_SCENE := preload("res://scenes/entities/PlayerGhost.tscn")

# jump handling
onready var coyoteTimer : Timer = $CoyoteTime
onready var jumpBuffer : Timer = $JumpBuffer
var was_on_floor : bool
var yCoordinateBeforeJump : float = global_position.y
export (int) var WALL_SLIDE_SPEED : int = 48
export (int) var MAX_WALL_SLIDE_SPEED : int = 128

# sprite textures
var left_arm_attached : bool = true
var right_arm_attached : bool = true
onready var leftArmPosition : Position2D = $LeftArmPosition
onready var rightArmPosition : Position2D = $RightArmPosition
const LIMB_SCENE := preload("res://scenes/entities/AssManLimb.tscn")
const BLOOD_PARTICLES := preload("res://scenes/particles/ArmBloodParticles.tscn")
const EXPLOSION_SCENE := preload("res://scenes/particles/ExplosionSprite.tscn")
var bloodParticlesLeft = null
var bloodParticlesRight = null
const damaged_1 := preload("res://assets/textures/entities/ass_man/spritesheet_no_left_arm.png")
const damaged_2 := preload("res://assets/textures/entities/ass_man/spritesheet_no_right_arm.png")

func _ready() -> void:
	uiHearts.initialize(100, 100)
	connect("player_damaged", uiHearts, "_on_Player_damage")

func _physics_process(_delta) -> void:
	if !stateMachine.state_logic_enabled:
		able_to_dash = false

	if dash == true:
		if Input.is_action_pressed("d") and dashingLeft:
			dash = false
			hurtbox.disabled = false
			dashingLeft = false
			MAX_SPEED /= 3
		elif Input.is_action_pressed("a") and dashingRight:
			dash = false
			hurtbox.disabled = false
			dashingRight = false
			MAX_SPEED /= 3

		if !Input.is_action_pressed("w") and !drag:
			motion.y = 0
			dragTimer.start()
		else:
			drag = false
		var ghostSprite := GHOST_SPRITE_SCENE.instance()
		ghostSprite.global_position = global_position
		ghostSprite.frame = sprite.frame
		ghostSprite.flip_h = sprite.flip_h
		ghostSprite.scale.x = sprite.scale.x
		get_tree().current_scene.add_child(ghostSprite)

	if able_to_dash:
		if Input.is_action_just_pressed("d") and dash == false:
			tappedRight += 1
			yield(get_tree().create_timer(.2), "timeout")
			tappedRight = 0
		if Input.is_action_pressed("d") and dash == false and tappedRight == 2:
			hurtbox.disabled = true
			dash = true
			dashingRight = true
			MAX_SPEED *= 3
			motion.x += 500
			yield(get_tree().create_timer(.3), "timeout")
			if dashingRight:
				hurtbox.disabled = false
				dash = false
				dashingRight = false
				MAX_SPEED /= 3
		if Input.is_action_just_pressed("a") and dash == false:
			tappedLeft += 1
			yield(get_tree().create_timer(.2), "timeout")
			tappedLeft = 0
		if Input.is_action_pressed("a") and dash == false and tappedLeft == 2:
			hurtbox.disabled = true
			dash = true
			dashingLeft = true
			MAX_SPEED *= 3
			motion.x -= 500
			yield(get_tree().create_timer(.5), "timeout")
			if dashingLeft:
				hurtbox.disabled = false
				dash = false
				dashingLeft = false
				MAX_SPEED /= 3

func _process(delta : float) -> void:
	uiLaxatives.text = str(laxatives)
	if sprite.flip_h == false:
		bulletPosition.position.x = -5
		bulletPosition.rotation = -0.23
		rightArmPosition.position.x = 6
		rightArmPosition.rotation = -2.93
		leftArmPosition.position.x = -5
		leftArmPosition.rotation = -2.93
		shootParticlesPos.position.x = -2

		if not bloodParticlesLeft == null:
			bloodParticlesLeft.position = leftArmPosition.position
		if not bloodParticlesRight == null:
			bloodParticlesRight.position = rightArmPosition.position
	else:
		bulletPosition.position.x = 5
		leftArmPosition.position.x = 5
		rightArmPosition.position.x = -6
		rightArmPosition.rotation = -0.23
		leftArmPosition.rotation = -0.23
		bulletPosition.rotation = -2.93
		shootParticlesPos.position.x = 2

		if not bloodParticlesLeft == null:
			bloodParticlesLeft.position = leftArmPosition.position
		if not bloodParticlesRight == null:
			bloodParticlesRight.position = rightArmPosition.position

func apply_damage_texture() -> void:
	if health <= 50 and left_arm_attached == true:
		left_arm_attached = false
		bloodParticlesLeft = BLOOD_PARTICLES.instance()
		bloodParticlesLeft.emitting = true
		bloodParticlesLeft.position = leftArmPosition.position
		add_child(bloodParticlesLeft)

		MAX_SPEED /= 2
		animation.playback_speed /= 2

		var limb = LIMB_SCENE.instance()
		limb.global_position = leftArmPosition.global_position
		limb.rotation = leftArmPosition.rotation
		get_tree().current_scene.add_child(limb)
		sprite.texture = damaged_1
	elif health <= 25 and right_arm_attached == true:
		right_arm_attached = false
		bloodParticlesRight = BLOOD_PARTICLES.instance()
		bloodParticlesRight.emitting = true
		bloodParticlesRight.position = rightArmPosition.position
		add_child(bloodParticlesRight)

		MAX_SPEED /= 2
		animation.playback_speed /= 2

		var limb := LIMB_SCENE.instance()
		limb.global_position = rightArmPosition.global_position
		limb.rotation = rightArmPosition.rotation
		get_tree().current_scene.add_child(limb)
		sprite.texture = damaged_2

func apply_gravity(delta : float) -> void:
	if coyoteTimer.is_stopped():
		motion.y += GlobalConstants.GRAVITY * delta
		motion.y += GlobalConstants.GRAVITY * delta

func execute_special_attack() -> void:
	var shitWave = shit_wave.instance()
	get_tree().current_scene.add_child(shitWave)

	if sprite.flip_h:
		shitWave.global_position = specialAttackPositionL.global_position
		shitWave.scale.x = -0.45
	else:
		shitWave.global_position = specialAttackPositionR.global_position
		shitWave.scale.x = 0.45

func apply_knockback(amount : Vector2) -> void:
	motion = amount.normalized() * ACCELERATION / 2

func apply_special_attack_controls() -> void:
	if x_input == 0:
		if Input.is_action_pressed("special_attack"):
			print(power_value)
			if can_fire == true:
				power_value += 1
				if power_value > 35:
					power_value = 0
					execute_special_attack()
					can_fire = false
					yield(get_tree().create_timer(15), "timeout")
					can_fire = true
		if Input.is_action_just_released("special_attack") and can_fire == true:
			power_value = 0
			can_fire = false
			yield(get_tree().create_timer(15), "timeout")
			can_fire = true

func apply_jumping() -> void:
	if is_on_floor() || !coyoteTimer.is_stopped():
		if x_input == 0:
			motion.x = lerp(motion.x, 0, FRICTION)
		if Input.is_action_just_pressed("w"):
			yCoordinateBeforeJump = global_position.y
			coyoteTimer.stop()
			motion.y = -JUMP_FORCE
	else:
		jumpBuffer.start()
		if Input.is_action_just_released("w") and motion.y < -JUMP_FORCE / 2:
			yCoordinateBeforeJump = global_position.y
			coyoteTimer.stop()
			motion.y = -JUMP_FORCE / 2
		
		if x_input == 0:
			motion.x = lerp(motion.x, 0, AIR_RESISTANCE)

func apply_movement(delta : float) -> void:
	x_input = Input.get_action_strength("d") - Input.get_action_strength("a")
	if x_input != 0:
		motion.x += x_input * ACCELERATION * delta
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
		sprite.flip_h = x_input < 0
		halfAss.flip_h = x_input < 0
	_check_bounce(delta)

func start_movement() -> void:
	was_on_floor = is_on_floor()
	motion = move_and_slide(motion, Vector2.UP)

#func loop_damage_checker():
#	print("called")
#	if hurtbox.disabled == false:
#		print("hurtbox enabled")
#		for body in $BulletDetection.get_overlapping_bodies():
#			if body.is_in_group("ForeignEnemyAttack"):
#				print("body has entered dmg")
#				apply_damage(body.damage)
#				enemyOrigin = body.transform.origin

func stunned() -> void:
	hurtbox.disabled = true
	stateMachine.state_logic_enabled = false
	stunned = true
	if stunnedTimer.is_stopped():
		stunnedTimer.wait_time = 1.25
		stunnedTimer.start()

func apply_damage(damage : float) -> void:
	apply_damage_texture()
	if enableBlood:
		for i in range(55):
			var blood_instance : Area2D = BLOOD_SCENE.instance()
			blood_instance.global_position = global_position
			get_tree().current_scene.call_deferred("add_child", blood_instance)
	if health <= 0:
		animation.playback_speed = 1
		return
	health -= damage
	stunned()
	camera.add_trauma(0.5)
	emit_signal("player_damaged", health)

func shoot() -> void:
	if can_fire_bullet == true:
		var shootingParticles = SHOOTING_PARTICLES.instance()
		shootingParticles.global_position = shootParticlesPos.global_position
		shootingParticles.emitting = true
		get_tree().current_scene.add_child(shootingParticles)
		
		can_fire_bullet = false
		var bulletType := bullet_type.instance()
		bulletType.global_position = bulletPosition.global_position
		bulletType.rotation = bulletPosition.rotation
		
		#juice
		var knockdir : Vector2 = Vector2.ZERO
		
		if sprite.flip_h:
			knockdir = Vector2(bulletType.recoil, 0)
		else:
			knockdir = Vector2(-bulletType.recoil, 0)
		apply_knockback(knockdir)
		animation.play("recoil")
		camera.add_trauma(bulletType.amount_of_screen_shake)
		
		get_tree().current_scene.add_child(bulletType)
		yield(get_tree().create_timer(bulletType.rate_of_fire), "timeout")
		can_fire_bullet = true

func _check_bounce(delta : float) -> void:
	if motion.y > 0:
		for raycast in bounceRaycasts.get_children():
			if raycast.is_colliding() and raycast.get_collision_normal() == Vector2.UP:
				raycast.get_collider().call_deferred("pounced", self)
				break

func get_wall_axis() -> int:
	var is_right_wall := test_move(transform, Vector2.RIGHT)
	var is_left_wall := test_move(transform, Vector2.LEFT)
	return int(is_left_wall) - int(is_right_wall)

func apply_wall_slide_jump(wall_axis) -> void:
	if Input.is_action_just_pressed("w"):
		motion.x = wall_axis * 154
		motion.y = -JUMP_FORCE * 1.5

func wall_slide_drop_check(delta : float) -> void:
	if Input.is_action_pressed("d"):
		motion.x = ACCELERATION * delta
	
	if Input.is_action_pressed("a"):
		motion.x = -ACCELERATION * delta

func wall_slide_fast_slide_check(delta : float) -> void:
	var max_slide_speed := WALL_SLIDE_SPEED
	if Input.is_action_pressed("s"):
		max_slide_speed = MAX_WALL_SLIDE_SPEED
	motion.y = min(motion.y + GlobalConstants.GRAVITY * delta, max_slide_speed)

func _on_IfVisible_screen_entered() -> void:
	var oldCamera := get_node(camera_in_level)
	oldCamera.current = false
	camera.current = true
	oldCamera.queue_free()
	ifVisible.queue_free()
	get_tree().current_scene.get_node("SewerBlock").get_node("Collider").disabled = false

func bounce() -> void:
	motion.y = -100

func instance_explosion_scene() -> void:
	if !wentThroughSaw:
		var explosion := EXPLOSION_SCENE.instance()
		explosion.global_position = global_position
		get_tree().current_scene.add_child(explosion)

func _on_PickUpDrops_body_entered(body) -> void:
	if body.is_in_group("ItemDrop"):
		body.pick_up_item()

func _on_Animation_animation_finished(anim_name : String) -> void:
	if anim_name == "death":
		var deathId := DEATH_ID_SCENE.instance()
		get_tree().current_scene.add_child(deathId)
	elif anim_name == "death_2":
		visible = false
		var deathId := DEATH_ID_SCENE.instance()
		get_tree().current_scene.add_child(deathId)

func _on_StunnedTimer_timeout() -> void:
	stunnedTimer.stop()
	stunnedTimer.wait_time = 1.25
	hurtbox.disabled = false
	stunned = false
	if health > 0:
		stateMachine.state_logic_enabled = true

func _on_BlockedTimer_timeout() -> void:
	shieldTimer.stop()
	shieldTimer.wait_time = 5

func _on_DragTimer_timeout() -> void:
	drag = true

func _on_Animation_animation_changed(old_name, new_name):
	if unlocking:
		animation.play("fall")
