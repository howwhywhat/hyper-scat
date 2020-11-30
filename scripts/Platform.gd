extends StaticBody2D

export (NodePath) var SPIKES_PATH
onready var spikes = get_node(SPIKES_PATH)

func _on_TurnOffSpikes_body_entered(body):
	spikes.enabled = false

func _on_TurnOffSpikes_body_exited(body):
	spikes.enabled = true
