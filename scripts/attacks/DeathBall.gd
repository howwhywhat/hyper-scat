extends RigidBody2D

onready var hitbox : CollisionShape2D = $Hitbox
onready var animation : AnimationPlayer = $Animation
onready var flashAnimation : AnimationPlayer = $BlinkAnimation

export (int) var projectile_speed
export (int) var damage

const IMPACT_SCENE := preload("res://scenes/particles/BulletImpact.tscn")

func apply_force() -> void:
	sleeping = false
	apply_impulse(Vector2(), Vector2(projectile_speed, 0).rotated(rotation))

func _on_IfVisible_screen_exited() -> void:
	queue_free()

func _on_DeathBall_body_entered(body) -> void:
	if body.is_in_group("Player") and body.hurtbox.disabled == false:
		body.apply_damage(damage)
	var impact := IMPACT_SCENE.instance()
	impact.global_position = global_position
	impact.rotation = rotation
	get_tree().current_scene.add_child(impact)
	queue_free()

func _on_Animation_animation_finished(anim_name) -> void:
	if anim_name == "spawn_in":
		animation.play("idle")
		hitbox.disabled = false
		apply_force()
