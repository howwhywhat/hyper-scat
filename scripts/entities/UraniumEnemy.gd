extends Enemy

var stunned = false

onready var sprite = $Texture
onready var damageTimer = $DamageTimer
onready var hurtbox = $PlayerDamage/Hurtbox
onready var state = $State
onready var animation = $Animation
onready var flashAnimation = $BlinkAnimation
onready var sleepingParticles = $SleepingParticles
onready var playerDetection = $PlayerDetection

func _process(_delta):
	if player != null:
		if global_position.x < player.global_position.x:
			sprite.flip_h = true
		else:
			sprite.flip_h = false

func _on_PlayerHurtDetection_body_entered(body):
	if body.is_in_group("Player"):
		damageTimer.start()

func _on_PlayerHurtDetection_body_exited(body):
	if body.is_in_group("Player"):
		damageTimer.stop()

func stunned():
	if hurtbox != null:
		hurtbox.disabled = true
	stunned = true
	yield(get_tree().create_timer(1), "timeout")
	if hurtbox != null:
		hurtbox.disabled = false
	stunned = false

func damage(value):
	if HEALTH > 0:
		stunned()
	HEALTH -= value

func apply_knockback(amount : Vector2):
	motion = amount.normalized() * MAX_SPEED / 2
	motion.x = lerp(motion.x, 0, 0.5)

func _on_DamageTimer_timeout():
	if stunned == false:
		player.apply_damage(1)

func _on_Animation_animation_finished(anim_name):
	if anim_name == "death":
		instance_explosion_scene()
		queue_free()
