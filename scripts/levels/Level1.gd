extends Node2D

onready var transitionLayer = $TransitionLayer

func _ready():
	transitionLayer._set_mask(transitionLayer.Transitions.grid)
	transitionLayer._set_fill(1.0)
	transitionLayer.shaderLayer.show_screen()
