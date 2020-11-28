extends StateMachine

onready var dust_particles = preload("res://scenes/particles/DustParticleEffect.tscn")

var state_logic_enabled = true

func _ready():
	add_state("idle")
	call_deferred("set_state", states.idle)

func _state_logic(delta):
	pass

func _get_transition(delta):
	match state:
		states.idle:
			parent.state.text = "idle"
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.animation.play("idle")

func _exit_state(old_state, new_state):
	pass
