extends Spatial

func _on_Play_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().change_scene("res://scenes/levels/Level1.tscn")

func _on_Exit_body_entered(body):
	if body.is_in_group("Player"):
		print("exit")
