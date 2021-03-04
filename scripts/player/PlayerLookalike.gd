extends RigidBody2D

onready var sprite : Sprite = $Sprite
const LEFT_ARM := preload("res://assets/textures/entities/ass_man/spritesheet_no_left_arm.png")
const RIGHT_ARM := preload("res://assets/textures/entities/ass_man/spritesheet_no_right_arm.png")

var player = null

func _process(_delta) -> void:
	if player != null:
		if !player.left_arm_attached:
			sprite.texture = LEFT_ARM
		elif !player.right_arm_attached:
			sprite.texture = RIGHT_ARM
