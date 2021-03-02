extends Node2D

export (NodePath) var TRAJECTORY_PATH
var trajectory

func _on_On_body_entered(body):
	if body.is_in_group("Player"):
		trajectory = get_node(TRAJECTORY_PATH)
		trajectory.enabled = true
		trajectory.y_level = 375
		$Off/CollisionShape2D.disabled = true

func _on_Off_body_entered(body):
	if body.is_in_group("Player"):
		trajectory = get_node(TRAJECTORY_PATH)
		trajectory.enabled = false

func _on_YLevelChange_body_entered(body):
	if body.is_in_group("Player"):
		trajectory = get_node(TRAJECTORY_PATH)
		trajectory.y_level = 247

func _on_On_body_exited(body):
	if body.is_in_group("Player"):
		$Off/CollisionShape2D.disabled = false
