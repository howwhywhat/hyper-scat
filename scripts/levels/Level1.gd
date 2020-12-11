extends Node2D

onready var transitionLayer = $TransitionLayer

func _ready():
	var levelIntro = preload("res://scenes/interface/LevelIntroduction.tscn").instance()
	levelIntro.get_node("Text").text = "LEVEL 1: INTO THE SEWERS"
	add_child(levelIntro)
	transitionLayer._set_mask(transitionLayer.Transitions.grid)
	transitionLayer._set_fill(1.0)
	transitionLayer.shaderLayer.show_screen()

func comeFromPokemonAttack():
	transitionLayer.shaderLayer.show_screen()
