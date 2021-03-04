extends Sprite

func _ready() -> void:
	randomize()
	modulate = Color(randf(), randf(), randf(), 1)
