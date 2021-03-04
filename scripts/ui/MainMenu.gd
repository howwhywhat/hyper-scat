extends Spatial

onready var transitionLayer := $TransitionLayer

func _on_Play_body_entered(body) -> void:
	if body.is_in_group("Player"):
		transitionLayer._set_mask(transitionLayer.Transitions.grid)
		transitionLayer.shaderLayer.hide_screen()
		yield(get_tree().create_timer(1.1), "timeout")
		get_tree().change_scene("res://scenes/levels/Level1.tscn")

func _on_Exit_body_entered(body) -> void:
	if body.is_in_group("Player"):
		transitionLayer._set_mask(transitionLayer.Transitions.grid)
		transitionLayer.shaderLayer.hide_screen()
		yield(get_tree().create_timer(1.1), "timeout")
		get_tree().quit()
