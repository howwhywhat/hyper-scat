extends Enemy

# general functionality
onready var collider = $Collider
onready var sleepingParticles = $SleepingParticles
onready var hurtbox = $PlayerDamage/Hurtbox
onready var animation = $Animation
onready var flashAnimation = $BlinkAnimation
onready var sprite = $Texture
onready var stateMachine = $StateMachine
onready var patrolTimer = $PatrolTimer
var woke_up = false
var stunned = false
var can_flip_h = true
var patrolling = false
var player_last_seen = null

export(float, 0.0, 5.0) var fill : float = 0.0 setget _set_fill

var tween_lock : bool = false

# raycasting / general ai
onready var floorLeft = $FloorLeft
onready var floorRight = $FloorRight
onready var wallLeft  = $WallLeft
onready var wallRight  = $WallRight

# player detection
onready var playerDetection = $PlayerDetectionWakeup
onready var attackHurtbox = $PlayerHitDetection/Hurtbox
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

# death shoot
var number_of_shots = 12
var BULLET_SCENE = preload("res://scenes/attacks/DeathBall.tscn")
onready var pivot = $Pivot
onready var bulletPosition = $Pivot/BulletPosition

func _process(_delta):
	if can_see() and player != null and can_flip_h:
		if global_position.x < player.global_position.x:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
	if sprite.flip_h and can_flip_h:
		jumpTop.cast_to = Vector2(12, 0)
		jumpBottom.cast_to = Vector2(12, 0)
	else:
		jumpTop.cast_to = Vector2(-12, 0)
		jumpBottom.cast_to = Vector2(-12, 0)

func move_towards_player(delta):
	var direction = (player.global_position - global_position).normalized()
	motion = motion.move_toward(direction * MAX_SPEED, 25 * delta)

func move_towards_last_seen(delta):
	var direction = (player_last_seen - global_position).normalized()
	motion = motion.move_toward(direction * MAX_SPEED, 25 * delta)

func can_jump():
	if is_on_floor() and jumpBottom.is_colliding() or jumpTop.is_colliding():
		return true
	else:
		return false

func shoot():
	player.lastHitEntity = self
	for shot in number_of_shots:
		var bullet = BULLET_SCENE.instance()
		pivot.rotation += (2 * PI / number_of_shots)
		bullet.global_position = bulletPosition.global_position
		bullet.rotation = pivot.rotation
		get_tree().current_scene.add_child(bullet)
		yield(get_tree().create_timer(.002), "timeout")

func damage(value):
	if HEALTH > 0:
		stunned()
	player.get_node("Camera").add_trauma(0.3)
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
				player_last_seen = player.global_position
				patrolTimer.start()
				patrolling = true
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
		visible = false
		attackHurtbox.queue_free()
		yield(get_tree().create_timer(2), "timeout")
		queue_free()
	elif anim_name == "death_2":
		instance_explosion_scene()
		visible = false
		attackHurtbox.queue_free()
		yield(get_tree().create_timer(2), "timeout")
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

func _on_PatrolTimer_timeout():
	patrolling = false
