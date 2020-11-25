extends CanvasLayer

func _on_Retry_pressed():
	get_tree().reload_current_scene()

func _on_Exit_pressed():
	get_tree().quit()
