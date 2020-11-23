extends KinematicBody2D

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
		apply_knockback(transform.origin - body.transform.origin)
