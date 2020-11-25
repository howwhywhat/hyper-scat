extends RigidBody2D

export (String) var bullet_name
export (String, "Shit") var bullet_type
export (int) var recoil
export (int) var damage

export (float) var rate_of_fire = 0.6
export (int, 0, 1500) var projectile_speed = 1500

export (PackedScene) var DEBRIS_SCENE

func _ready():
	print(rotation)
	apply_impulse(Vector2(), Vector2(projectile_speed, 0).rotated(rotation))

func _on_IfVisible_screen_exited():
	queue_free()

func _on_Bullet_body_entered(body):
	if body.is_in_group("ForeignEntities"):
		body.damage(damage)
		queue_free()
	elif body.is_in_group("WallTiles"):
		sleeping = true
		$Animation.play("fall_in")
		var debris = DEBRIS_SCENE.instance()
		debris.global_position = global_position
		get_tree().current_scene.add_child(debris)
	else:
		queue_free()

func _on_Animation_animation_finished(anim_name):
	if anim_name == "autoload":
		$Animation.play("in_air")
	
	if anim_name == "fall_in":
		queue_free()

func _on_Animation_animation_started(anim_name):
	print(anim_name)
