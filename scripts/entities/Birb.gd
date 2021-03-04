extends Area2D

onready var animation : AnimationPlayer = $Animation
onready var linePosition : Position2D = $Line/Position
onready var head : Sprite = $Head

func _process(_delta) -> void:
	head.global_position = linePosition.global_position - Vector2(20, 0)

func start_head_extend() -> void:
	animation.play("head_extend")
