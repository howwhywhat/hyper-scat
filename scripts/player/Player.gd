extends KinematicBody2D

# general
var health = 100
var stunned = false
onready var DEATH_ID_SCENE = preload("res://scenes/interface/DeathUI.tscn")
onready var SHOOTING_PARTICLES = preload("res://scenes/particles/ShootingParticles.tscn")

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
const GRAVITY = 200
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
onready var halfAss = $HalfAss
onready var sprite = $CharacterSprite
onready var camera = $Camera
onready var ifVisible = $IfVisible
onready var bulletPosition = $BulletPosition
onready var shootParticlesPos = $ShootingParticlesPosition
onready var bounceRaycasts = $BounceRaycasts
onready var uiHearts = get_tree().current_scene.get_node("UI").get_node("Hearts")

func _ready():
	uiHearts.initialize(100, 100)
	connect("player_damaged", uiHearts, "_on_Player_damage")

func _process(_delta):
	if sprite.flip_h == false:
		bulletPosition.position.x = -5
		bulletPosition.rotation = -0.23
		shootParticlesPos.position.x = -2
	else:
		bulletPosition.position.x = 5
		bulletPosition.rotation = -2.93
		shootParticlesPos.position.x = 2

func apply_gravity(delta):
	motion.y += GRAVITY * delta
	motion.y += GRAVITY * delta

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
	if is_on_floor():
		if x_input == 0:
			motion.x = lerp(motion.x, 0, FRICTION)
		if Input.is_action_just_pressed("w"):
			motion.y = -JUMP_FORCE
	else:
		if Input.is_action_just_released("w") and motion.y < -JUMP_FORCE / 2:
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
	motion = move_and_slide(motion, Vector2.UP)

func apply_empty_movement(delta):
	motion.x = lerp(motion.x, 0, FRICTION)
	motion = move_and_slide(motion, Vector2.UP)

func loop_damage_checker():
	for body in $BulletDetection.get_overlapping_bodies():
		apply_damage(body.damage)

func stunned():
	stunned = true
	yield(get_tree().create_timer(1.25), "timeout")
	stunned = false

func apply_damage(damage):
	if stunned == false:
		health -= damage
		camera.add_trauma(0.5)
		emit_signal("player_damaged", health)
	
	if health <= 0 and stunned == false:
		var deathId = DEATH_ID_SCENE.instance()
		get_tree().current_scene.add_child(deathId)
	elif health > 0 and stunned == false:
		stunned()

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

func _on_IfVisible_screen_entered():
	var oldCamera = get_node(camera_in_level)
	oldCamera.current = false
	camera.current = true
	oldCamera.queue_free()
	ifVisible.queue_free()
