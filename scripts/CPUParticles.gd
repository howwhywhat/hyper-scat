extends CPUParticles2D

export (float) var time

func _ready():
	yield(get_tree().create_timer(time), "timeout")
	queue_free()
