extends StaticBody2D

export (NodePath) var SPIKES_PATH : NodePath
onready var spikes := get_node(SPIKES_PATH)

func _on_TurnOffSpikes_body_entered(body) -> void:
	if body.is_in_group("Player"):
		spikes.enabled = false

func _on_TurnOffSpikes_body_exited(body) -> void:
	if body.is_in_group("Player"):
		spikes.enabled = true
