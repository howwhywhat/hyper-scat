extends CanvasLayer

onready var animation : AnimationPlayer = $Animation

func _input(event) -> void:
	if event.is_action_pressed("shoot"):
		get_tree().change_scene("res://scenes/interface/MainMenu.tscn")

func _on_Animation_animation_finished(anim_name : String) -> void:
	if anim_name == "autoload":
		yield(get_tree().create_timer(3.5), "timeout")
		animation.play("end")
	if anim_name == "end":
		get_tree().change_scene("res://scenes/interface/MainMenu.tscn")
