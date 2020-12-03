extends RigidBody2D

onready var animation = $Animation

const GRAVITY = 200
const MAX_SPEED = 128
var motion = Vector2.ZERO
var player = null setget set_player
var randomxValues = [25, -25, 15, -15]
var randomyValues = [-15, -10, -5, -20]

func _ready():
	set_process(false)
	randomize()
	var xResult = randomxValues[randi() % randomxValues.size()]
	var yResult = randomyValues[randi() % randomyValues.size()]
	apply_central_impulse(Vector2(xResult, yResult))

func _process(delta):
	move_towards_player(delta)

func pick_up_item():
	animation.play("pick_up")

func set_player(new_value):
	player = new_value

func move_towards_player(delta):
	var direction = (player.global_position - global_position).normalized()
	apply_central_impulse(direction)

func _on_Animation_animation_finished(anim_name):
	if anim_name == "pick_up":
		print(player.laxatives)
		player.laxatives += 1
		queue_free()
