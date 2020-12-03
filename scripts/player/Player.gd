extends KinematicBody2D

# general
var health = 100
var laxatives = 0
var stunned = false
onready var DEATH_ID_SCENE = preload("res://scenes/interface/DeathUI.tscn")
onready var SHOOTING_PARTICLES = preload("res://scenes/particles/ShootingParticles.tscn")
var enemyOrigin = Vector2.ZERO

# bullet type/weaponry
export (PackedScene) var bullet_type
var can_fire_bullet = true

# signals
signal player_damaged(damage)

# camera control
export (NodePath) var camera_in_level

# movement
const ACCELERATION = 512
const MAX_SPEED = 64
var FRICTION = 0.25
const AIR_RESISTANCE  = 0.02
const JUMP_FORCE = 128

var motion = Vector2.ZERO
var x_input = 0

# attacks
var power_value = 0
var can_fire = true
onready var shit_wave = preload("res://scenes/attacks/ShitWave.tscn")

# variables
onready var animation = $Animation
onready var state = $State
onready var stateMachine = $StateMachine
onready var halfAss = $HalfAss
onready var sprite = $CharacterSprite
onready var camera = $Camera
onready var ifVisible = $IfVisible
onready var bulletPosition = $BulletPosition
onready var shootParticlesPos = $ShootingParticlesPosition
onready var bounceRaycasts = $BounceRaycasts
onready var hurtbox = $BulletDetection/BulletHitbox

export (NodePath) var UI_NODE
onready var ui = get_node(UI_NODE)
onready var uiHearts = ui.get_node("Hearts")
onready var uiLaxatives = ui.get_node("Laxatives").get_node("Label")

# jump handling
onready var coyoteTimer = $CoyoteTime
onready var jumpBuffer = $JumpBuffer
var was_on_floor
var yCoordinateBeforeJump = global_position.y
export (int) var WALL_SLIDE_SPEED = 48
export (int) var MAX_WALL_SLIDE_SPEED = 128

# sprite textures
var left_arm_attached = true
var right_arm_attached = true
onready var leftArmPosition = $LeftArmPosition
onready var rightArmPosition = $RightArmPosition
var LIMB_SCENE = preload("res://scenes/entities/AssManLimb.tscn")
var damaged_1 = preload("res://assets/textures/entities/ass_man/spritesheet_no_left_arm.png")
var damaged_2 = preload("res://assets/textures/entities/ass_man/spritesheet_no_right_arm.png")

func _ready():
	uiHearts.initialize(100, 100)
	connect("player_damaged", uiHearts, "_on_Player_damage")

func _process(delta):
	uiLaxatives.text = str(laxatives)
	if sprite.flip_h == false:
		bulletPosition.position.x = -5
		bulletPosition.rotation = -0.23
		rightArmPosition.position.x = 6
		rightArmPosition.rotation = -2.93
		leftArmPosition.position.x = -5
		leftArmPosition.rotation = -2.93
		shootParticlesPos.position.x = -2
	else:
		bulletPosition.position.x = 5
		leftArmPosition.position.x = 5
		rightArmPosition.position.x = -6
		rightArmPosition.rotation = -0.23
		leftArmPosition.rotation = -0.23
		bulletPosition.rotation = -2.93
		shootParticlesPos.position.x = 2

func apply_damage_texture():
	if health <= 50 and left_arm_attached == true:
		left_arm_attached = false
		var limb = LIMB_SCENE.instance()
		limb.global_position = leftArmPosition.global_position
		limb.rotation = leftArmPosition.rotation
		get_tree().current_scene.add_child(limb)
		sprite.texture = damaged_1
	elif health <= 25 and right_arm_attached == true:
		right_arm_attached = false
		var limb = LIMB_SCENE.instance()
		limb.global_position = rightArmPosition.global_position
		limb.rotation = rightArmPosition.rotation
		get_tree().current_scene.add_child(limb)
		sprite.texture = damaged_2

func apply_gravity(delta):
	if coyoteTimer.is_stopped():
		motion.y += GlobalConstants.GRAVITY * delta
		motion.y += GlobalConstants.GRAVITY * delta

func execute_special_attack():
	var shitWave = shit_wave.instance()
	shitWave.global_position = global_position
	shitWave.global_position.y -= 32
	shitWave.global_position.x += 15
	get_tree().current_scene.add_child(shitWave)

func apply_knockback(amount : Vector2):
	motion = amount.normalized() * ACCELERATION / 2

func apply_special_attack_controls():
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

func apply_jumping():
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

func apply_movement(delta):
	x_input = Input.get_action_strength("d") - Input.get_action_strength("a")
	if x_input != 0:
		motion.x += x_input * ACCELERATION * delta
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
		sprite.flip_h = x_input < 0
		halfAss.flip_h = x_input < 0
	_check_bounce(delta)

func start_movement():
	was_on_floor = is_on_floor()
	motion = move_and_slide(motion, Vector2.UP)

func loop_damage_checker():
	for body in $BulletDetection.get_overlapping_bodies():
		if body.is_in_group("ForeignEnemyAttack"):
			apply_damage(body.damage)
			enemyOrigin = body.transform.origin

func stunned():
	hurtbox.disabled = true
	stunned = true
	yield(get_tree().create_timer(1.25), "timeout")
	hurtbox.disabled = false
	stunned = false

func apply_damage(damage):
	apply_damage_texture()
	if health <= 0:
		var deathId = DEATH_ID_SCENE.instance()
		get_tree().current_scene.add_child(deathId)
		return
	health -= damage
	stunned()
	camera.add_trauma(0.5)
	emit_signal("player_damaged", health)

func shoot():
	if can_fire_bullet == true:
		var shootingParticles = SHOOTING_PARTICLES.instance()
		shootingParticles.global_position = shootParticlesPos.global_position
		shootingParticles.emitting = true
		get_tree().current_scene.add_child(shootingParticles)
		
		can_fire_bullet = false
		var bulletType = bullet_type.instance()
		bulletType.global_position = bulletPosition.global_position
		bulletType.rotation = bulletPosition.rotation
		
		#juice
		var knockdir = Vector2.ZERO
		
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

func _check_bounce(delta):
	if motion.y > 0:
		for raycast in bounceRaycasts.get_children():
			if raycast.is_colliding() and raycast.get_collision_normal() == Vector2.UP:
				raycast.get_collider().call_deferred("pounced", self)
				break

func get_wall_axis():
	var is_right_wall = test_move(transform, Vector2.RIGHT)
	var is_left_wall = test_move(transform, Vector2.LEFT)
	return int(is_left_wall) - int(is_right_wall)

func apply_wall_slide_jump(wall_axis):
	if Input.is_action_just_pressed("w"):
		motion.x = wall_axis * 154
		motion.y = -JUMP_FORCE * 1.5

func wall_slide_drop_check(delta):
	if Input.is_action_pressed("d"):
		motion.x = ACCELERATION * delta
	
	if Input.is_action_pressed("a"):
		motion.x = -ACCELERATION * delta

func wall_slide_fast_slide_check(delta):
	var max_slide_speed = WALL_SLIDE_SPEED
	if Input.is_action_pressed("s"):
		max_slide_speed = MAX_WALL_SLIDE_SPEED
	motion.y = min(motion.y + GlobalConstants.GRAVITY * delta, max_slide_speed)

func _on_IfVisible_screen_entered():
	var oldCamera = get_node(camera_in_level)
	oldCamera.current = false
	camera.current = true
	oldCamera.queue_free()
	ifVisible.queue_free()
	get_tree().current_scene.get_node("SewerBlock").get_node("Collider").disabled = false

func bounce():
	motion.y = -100

func _on_PickUpDrops_body_entered(body):
	if body.is_in_group("ItemDrop"):
		body.pick_up_item()

func _on_DropMoveToRadius_body_entered(body):
	if body.is_in_group("ItemDrop"):
		print("body in")
		body.set_process(true)

func _on_DropMoveToRadius_body_exited(body):
	if body.is_in_group("ItemDrop"):
		print("body out")
		body.set_process(false)
