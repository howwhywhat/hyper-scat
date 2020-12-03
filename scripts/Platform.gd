extends StaticBody2D

export (NodePath) var SPIKES_PATH
onready var spikes = get_node(SPIKES_PATH)

func _on_TurnOffSpikes_body_entered(body):
	if body.is_in_group("Player"):
		spikes.enabled = false

func _on_TurnOffSpikes_body_exited(body):
	if body.is_in_group("Player"):
		spikes.enabled = true
