extends CanvasLayer

func _input(event) -> void:
	if event.is_action_pressed("shoot"):
		$Animation.stop()
		offset.x = 0

func _on_Retry_pressed() -> void:
	layer -= 2
	get_tree().current_scene.transitionLayer._set_mask(get_tree().current_scene.transitionLayer.Transitions.grid)
	get_tree().current_scene.transitionLayer._set_fill(0.0)
	get_tree().current_scene.transitionLayer.shaderLayer.hide_screen()
	yield(get_tree().create_timer(1), "timeout")
	get_tree().change_scene(get_tree().current_scene.filename)

func _on_Exit_pressed() -> void:
	layer -= 2
	get_tree().current_scene.transitionLayer._set_mask(get_tree().current_scene.transitionLayer.Transitions.grid)
	get_tree().current_scene.transitionLayer._set_fill(0.0)
	get_tree().current_scene.transitionLayer.shaderLayer.hide_screen()
	yield(get_tree().create_timer(1), "timeout")
	get_tree().change_scene("res://scenes/interface/MainMenu.tscn")
