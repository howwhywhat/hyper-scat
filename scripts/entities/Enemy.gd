extends KinematicBody2D

export (int) var MAX_SPEED = 15
export (int) var HEALTH = 100
var motion = Vector2.ZERO

# abstract method
func damage(value):
	pass
