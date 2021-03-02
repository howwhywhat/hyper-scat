extends RigidBody2D

onready var hitbox = $Hitbox
onready var animation = $Animation
onready var flashAnimation = $BlinkAnimation

export (int) var projectile_speed
export (int) var damage

var IMPACT_SCENE = preload("res://scenes/particles/BulletImpact.tscn")

func apply_force():
	sleeping = false
	apply_impulse(Vector2(), Vector2(projectile_speed, 0).rotated(rotation))

func _on_IfVisible_screen_exited():
	queue_free()

func _on_DeathBall_body_entered(body):
	if body.is_in_group("Player") and body.hurtbox.disabled == false:
		body.apply_damage(damage)
	var impact = IMPACT_SCENE.instance()
	impact.global_position = global_position
	impact.rotation = rotation
	get_tree().current_scene.add_child(impact)
	queue_free()

func _on_Animation_animation_finished(anim_name):
	if anim_name == "spawn_in":
		animation.play("idle")
		hitbox.disabled = false
		apply_force()
