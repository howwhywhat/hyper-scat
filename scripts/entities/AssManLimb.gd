extends RigidBody2D

onready var sprite = $Texture

export (int) var projectile_speed

func _ready():
	apply_impulse(Vector2(), Vector2(projectile_speed, 0).rotated(rotation))

func _on_IfVisible_screen_exited():
	queue_free()