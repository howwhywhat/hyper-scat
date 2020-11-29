extends Spatial

onready var transitionLayer = $TransitionLayer

var scene

func _ready():
	Engine.time_scale = 1
	scene = get_tree().current_scene
	get_tree().get_root().remove_child(scene)
	transitionLayer.shaderLayer.show_screen()
