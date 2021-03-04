extends Particles2D

export (float) var time : float

func _ready() -> void:
	yield(get_tree().create_timer(time), "timeout")
	queue_free()
