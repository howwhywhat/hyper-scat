extends "res://scripts/entities/Enemy.gd"

# general functionality
onready var collider = $Collider
onready var sleepingParticles = $SleepingParticles
onready var hurtbox = $PlayerDamage/Hurtbox
onready var animation = $Animation
onready var sprite = $Texture
onready var stunTween = $StunTween
onready var stateMachine = $StateMachine
var woke_up = false
var stunned = false
const JUMP = 190

var BLOOD_SCENE = preload("res://scenes/particles/BloodShitParticles.tscn")

export(float, 0.0, 5.0) var fill : float = 0.0 setget _set_fill

var tween_lock : bool = false

# raycasting / general ai
onready var floorLeft = $FloorLeft
onready var floorRight = $FloorRight
onready var wallLeft  = $WallLeft
onready var wallRight  = $WallRight

# player detection
onready var playerDetection = $PlayerDetectionWakeup
onready var leftAttackDetection = $LeftPlayerAttackDetection
onready var rightAttackDetection = $RightPlayerAttackDetection
onready var chaseHitbox = $PlayerChaseCast

# jumping
onready var jumpTop = $JumpTop
onready var jumpBottom = $JumpBottom

# attacks
onready var POKEMON_SCENE = preload("res://scenes/levels/PokemonAttack.tscn")

# debugging
onready var state = $State

func _process(_delta):
	if can_see() and player != null:
		if global_position.x < player.global_position.x:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
	if sprite.flip_h:
		jumpTop.cast_to = Vector2(12, 0)
		jumpBottom.cast_to = Vector2(12, 0)
	else:
		jumpTop.cast_to = Vector2(-12, 0)
		jumpBottom.cast_to = Vector2(-12, 0)

func move_towards_player(delta):
	var direction = (player.global_position - global_position).normalized()
	motion = motion.move_toward(direction * MAX_SPEED, 25 * delta)

func _apply_gravity(delta):
	motion.y += GlobalConstants.GRAVITY * delta
	motion.y += GlobalConstants.GRAVITY * delta

func move():
	motion = move_and_slide(motion, Vector2.UP)

func jump():
	motion.y -= JUMP

func can_jump():
	if is_on_floor() and jumpBottom.is_colliding() or jumpTop.is_colliding():
		return true
	else:
		return false

func stop_movement():
	motion = move_and_slide(Vector2.ZERO, Vector2.UP)

func damage(value):
	if HEALTH > 0:
		stunned()
	HEALTH -= value

func in_sight():
	var dir = Vector2(player.position.x - position.x, player.position.y - position.y)
	chaseHitbox.cast_to = dir
	if chaseHitbox.get_collider() != player:
		return false
	else:
		return true

func can_see():
	if playerDetection != null:
		if playerDetection.overlaps_body(player):
			if in_sight():
				return true
		else:
			chaseHitbox.cast_to = Vector2.ZERO
			return false

func stunned():
	if hurtbox != null:
		hurtbox.disabled = true
	stunned = true
	yield(get_tree().create_timer(1), "timeout")
	if hurtbox != null:
		hurtbox.disabled = false
	stunned = false

func apply_knockback(amount : Vector2):
	motion = amount.normalized() * MAX_SPEED / 2
	motion.x = lerp(motion.x, 0, 0.5)

func set_player(new_value):
	player = new_value

func _on_Animation_animation_finished(anim_name):
	if anim_name == "idle":
		woke_up = true
	elif anim_name == "death":
		queue_free()

func _start_pokemon_fight_scene():
	var pokemonScene = POKEMON_SCENE.instance()
	pokemonScene.garbageEntity = self
	pokemonScene.player = player
	get_tree().current_scene.get_node("TransitionLayer")._set_mask(get_tree().current_scene.get_node("TransitionLayer").Transitions.pixel_swirl)
	get_tree().current_scene.get_node("TransitionLayer")._set_fill(0.0)
	get_tree().current_scene.get_node("TransitionLayer").shaderLayer.hide_screen()
	yield(get_tree().create_timer(1.15), "timeout")
	get_tree().get_root().add_child(pokemonScene)

func instance_blood_particles():
	var blood = BLOOD_SCENE.instance()
	blood.global_position = global_position
	blood.emitting = true
	get_tree().current_scene.add_child(blood)

# use tweening and use it for death and stun
func stunned_vfx():
	fill = 5.0
	if tween_lock or fill == 0.0:
		return
	tween_lock = true
	if stunTween.interpolate_property(self, "fill", fill, 0.0, 1,
		Tween.TRANS_LINEAR, Tween.EASE_OUT):
		if stunTween.start():
			yield(stunTween, "tween_completed")
			tween_lock = false

func _set_fill(val:float):
	fill = clamp(val, 0.0, 5.0)
	sprite.material.set_shader_param("flash_modifier", fill)

func _on_PlayerHitDetection_body_entered(body):
	if body.is_in_group("Player") and body.hurtbox.disabled == false:
		body.apply_damage(25)
		yield(get_tree().create_timer(0.20), "timeout")
		if body.health > 0:
			_start_pokemon_fight_scene() 

func pounced(bouncer):
	damage(5)
	bouncer.bounce()
