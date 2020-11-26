extends KinematicBody

var gravity = -9.8
var motion = Vector3.ZERO

var camera
var animation

const SPEED = 6
const ACCELERATION = 2
const FRICTION = 5

func _ready():
	camera = get_node("../Camera").get_global_transform()
	animation = get_node("../PlayerAnimation")

func _physics_process(delta):
	var direction = Vector3.ZERO

	if Input.is_action_pressed("a"):
		$Sprite3D.flip_h = true
		animation.play("player_walking")
		direction += -camera.basis[0]
	elif Input.is_action_pressed("d"):
		$Sprite3D.flip_h = false
		direction += camera.basis[0]
		animation.play("player_walking")
	else:
		animation.play("idle")
	
	direction.y = 0
	direction = direction.normalized()
	
	motion.y += delta * gravity
	var hv = motion
	hv.y = 0
	
	var new_pos = direction * SPEED
	var accel = FRICTION
	
	if (direction.dot(hv) > 0):
		accel = ACCELERATION
	
	hv = hv.linear_interpolate(new_pos, accel * delta)
	
	motion.x = hv.x
	motion.z = hv.z
	motion = move_and_slide(motion, Vector3(0, 1, 0))
