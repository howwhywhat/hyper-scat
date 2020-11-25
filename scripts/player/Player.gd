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
const FRICTION = 0.25
const AIR_RESISTANCE  = 0.02
const GRAVITY = 200
const JUMP_FORCE = 128

var motion = Vector2.ZERO
var x_input = 0

# attacks
var power_value = 0
var can_fire = true
onready var shit_wave = preload("res://scenes/ShitWave.tscn")

# variables
onready var animation = $Animation
onready var state = $State
onready var sprite = $CharacterSprite
onready var camera = $Camera
onready var ifVisible = $IfVisible
onready var bulletPosition = $BulletPosition
onready var shootParticlesPos = $ShootingParticlesPosition
onready var uiHearts = get_tree().current_scene.get_node("UI").get_node("Hearts")

func _ready():
	uiHearts.initialize(100, 100)
	connect("player_damaged", uiHearts, "_on_Player_damage")

func _process(_delta):
	if sprite.flip_h == true:
		bulletPosition.position.x = -4
		shootParticlesPos.position.x = -2
	else:
		bulletPosition.position.x = 4
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
	motion = amount.normalized() * ACCELERATION

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
	
	motion = move_and_slide(motion, Vector2.UP)

func loop_damage_checker():
	for body in $BulletDetection.get_overlapping_bodies():
		apply_damage(body.damage)
		apply_knockback(transform.origin - body.transform.origin)

func stunned():
	stunned = true
	yield(get_tree().create_timer(1.25), "timeout")
	stunned = false

func apply_damage(damage):
	health -= damage
	camera.add_trauma(0.5)
	emit_signal("player_damaged", health)
	
	if health <= 0:
		$Animation.play("death")
		var deathId = DEATH_ID_SCENE.instance()
		get_tree().current_scene.add_child(deathId)
	else:
		stunned()

func shoot():
	if can_fire_bullet == true:
		var shootingParticles = SHOOTING_PARTICLES.instance()
		shootingParticles.global_position = shootParticlesPos.global_position
		shootingParticles.emitting = true
		
		if sprite.flip_h == true:
			shootingParticles.get_process_material().set_gravity(Vector3(-30, 0, 0))
		
		get_tree().current_scene.add_child(shootingParticles)
		
		can_fire_bullet = false
		var bulletType = bullet_type.instance()
		bulletType.global_position = bulletPosition.global_position
		bulletType.rotation = bulletPosition.get_angle_to(get_global_mouse_position())
		get_tree().current_scene.add_child(bulletType)
		yield(get_tree().create_timer(bulletType.rate_of_fire), "timeout")
		can_fire_bullet = true

func _on_IfVisible_screen_entered():
	var oldCamera = get_node(camera_in_level)
	oldCamera.current = false
	camera.current = true
	oldCamera.queue_free()
	ifVisible.queue_free()
