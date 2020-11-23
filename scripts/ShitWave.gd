extends Area2D

func _ready():
	set_physics_process(false)
	$Animations.play("spawn_In")

func _physics_process(delta):
	position.x += 2

func _on_IfVisible_screen_exited():
	$Animations.play("exit")

func _on_Animations_animation_finished(anim_name):
	if anim_name == "spawn_In":
		set_physics_process(true)
		$Animations.play("wade")

	if anim_name == "exit":
		queue_free()