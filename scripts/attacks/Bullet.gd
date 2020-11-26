extends RigidBody2D

export (String) var bullet_name
export (String, "Shit") var bullet_type
export (int) var recoil
export (int) var damage
export (float) var amount_of_screen_shake

export (float) var rate_of_fire = 0.6
export (int, 0, 1500) var projectile_speed = 1500

func _ready():
	apply_impulse(Vector2(), Vector2(projectile_speed, 0).rotated(rotation))
