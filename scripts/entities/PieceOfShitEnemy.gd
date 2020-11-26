extends "res://scripts/entities/Enemy.gd"

# general functionality
onready var collider = $Collider
onready var animation = $Animation
onready var sprite = $Texture
var woke_up = false
var been_bounced = false

# raycasting / general ai
onready var floorLeft = $FloorLeft
onready var floorRight = $FloorRight
onready var wallLeft  = $WallLeft
onready var wallRight  = $WallRight
onready var mouthPosition = $MouthPosition

# player detection
onready var playerDetection = $PlayerDetectionWakeup
onready var playerChaseDetection = $PlayerDetectionChase
onready var leftAttackDetection = $LeftPlayerAttackDetection
onready var rightAttackDetection = $RightPlayerAttackDetection
onready var chaseHitbox = $PlayerDetectionChase/Collider

# debugging
onready var stateLabel = $Label

var player = null setget set_player

func _ready():
	pass

func _process(_delta):
	if sprite.flip_h == true:
		mouthPosition.position.x = -24
	else:
		mouthPosition.position.x = 24

func move_towards_player(delta):
	var direction = (player.global_position - global_position).normalized()
	motion = motion.move_toward(direction * MAX_SPEED, 25 * delta)

func set_player(new_player):
	player = new_player

func stop_movement():
	motion = move_and_slide(Vector2.ZERO, Vector2.UP)

func move():
	motion.y += 5
	motion = move_and_slide(motion, Vector2.UP)

func damage(value):
	HEALTH -= value

func _on_Animation_animation_finished(anim_name):
	if anim_name == "wake_up":
		woke_up = true
	elif anim_name == "death":
		queue_free()

func _on_PlayerDetectionWakeup_body_entered(body):
	if body.is_in_group("Player"):
		player = body

func _on_PlayerDetectionChase_body_exited(body):
	$StateMachine.call_deferred("set_state", $StateMachine.states.asleep)
	stop_movement()

func pounced(bouncer):
	damage(9999)
