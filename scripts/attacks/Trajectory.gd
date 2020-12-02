extends Line2D

export (PackedScene) var SPIKE_TYPE
export (NodePath) var PLAYER
onready var player = get_node(PLAYER)

# jump trajectory handling
var max_points = 900
var outside_delta
var y_level = 247
export (bool) var enabled = true

func _process(delta):
	outside_delta = delta

func update_trajectory(delta):
	clear_points()
	var pos = player.global_position
	var vel = player.global_transform.x * player.motion
	for i in max_points:
		add_point(pos)
		vel.y += player.GRAVITY * delta
		pos += vel * delta
		if pos.y > y_level:
			var spike = SPIKE_TYPE.instance()
			spike.global_position = pos
			get_tree().current_scene.add_child(spike)
			break

func _on_Timer_timeout():
	if enabled:
		update_trajectory(outside_delta)
