extends StaticBody2D

const PLAYER_LOOKALIKE := preload("res://scenes/entities/PlayerLookalike.tscn")

export (NodePath) var trajectory_path : NodePath
export (float) var time : float = 0.6

export (NodePath) var wall_half_path : NodePath

onready var playerDetection : CollisionShape2D = $PlayerDetection/Collider
onready var animation : AnimationPlayer = $Animation
onready var timer : Timer = $Timer

func _ready() -> void:
	timer.wait_time = time

func _on_PlayerDetection_body_entered(body) -> void:
	if body.is_in_group("Player"):
		playerDetection.queue_free()
		animation.play("close_to_crumbling")
		timer.start()

func _on_Timer_timeout() -> void:
	animation.play("crumbling")

func wall_half_turn_visible() -> void:
	var wall_half := get_node(wall_half_path)
	var tween : Tween = wall_half.get_node("Tween")
	tween.interpolate_property(wall_half, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.5, Tween.TRANS_LINEAR)
	tween.start()

func _on_PlayerTurnoff_body_entered(body):
	if body.is_in_group("Player") and !body.wentThroughSaw:
		var lookalike := PLAYER_LOOKALIKE.instance()
		get_tree().current_scene.add_child(lookalike)
		lookalike.player = body
		lookalike.global_position = body.global_position
		lookalike.sprite.flip_h = body.sprite.flip_h
		lookalike.sprite.scale = body.sprite.scale
		lookalike.scale = body.scale
		
		var trajectory = get_node(trajectory_path)
		trajectory.enabled = false
		body.visible = false
		body.stateMachine.movement_enabled = false
		body.enableBlood = false
		body.apply_damage(1000)
