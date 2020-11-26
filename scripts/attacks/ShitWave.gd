extends Area2D

onready var animation = $Animations

export (int) var damage = 2.0

func _ready():
	set_physics_process(false)
	animation.play("spawn_In")

func _physics_process(delta):
	position.x += 2

func _on_IfVisible_screen_exited():
	animation.play("exit")

func _on_Animations_animation_finished(anim_name):
	if anim_name == "spawn_In":
		set_physics_process(true)
		animation.play("wade")

	if anim_name == "exit":
		queue_free()

func _on_ShitWave_body_entered(body):
	if body.is_in_group("TileWall"):
		animation.play("exit")
	elif body.is_in_group("ForeignEntities"):
		animation.play("exit")
		body.damage(damage)
