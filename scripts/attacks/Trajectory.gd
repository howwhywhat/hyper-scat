extends Line2D

export (PackedScene) var SPIKE_TYPE
export (NodePath) var PLAYER
onready var player : KinematicBody2D = get_node(PLAYER)

# jump trajectory handling
var max_points : int = 900
var outside_delta : float
var y_level : float = 247
export (bool) var enabled := true

func _process(delta : float) -> void:
	outside_delta = delta

func update_trajectory(delta : float) -> void:
	clear_points()
	var pos = player.global_position
	var vel = player.global_transform.x * player.motion
	for i in max_points:
		add_point(pos)
		vel.y += GlobalConstants.GRAVITY * delta
		pos += vel * delta
		if pos.y > y_level:
			var spike = SPIKE_TYPE.instance()
			spike.global_position = pos
			get_tree().current_scene.add_child(spike)
			break

func _on_Timer_timeout() -> void:
	if enabled:
		update_trajectory(outside_delta)
