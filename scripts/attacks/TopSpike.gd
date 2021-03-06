extends RigidBody2D

export (int) var damage = 25

const PARTICLES_SCENE := preload("res://scenes/particles/TopSpikeParticle.tscn")
var particles

onready var animation : AnimationPlayer = $Animation
onready var flashAnimation : AnimationPlayer = $BlinkAnimation
onready var playerDetection : RayCast2D = $PlayerDetection

func _process(_delta) -> void:
	if not playerDetection == null:
		if playerDetection.is_colliding():
			var body := playerDetection.get_collider()
			if body.is_in_group("Player"):
				playerDetection.queue_free()
				gravity_scale = 3
				animation.play("attack")

func _on_TopSpike_body_entered(body) -> void:
	print("body detected")
	if body.is_in_group("Player") and body.hurtbox.disabled == false:
		body.lastHitEntity = self
		particles = PARTICLES_SCENE.instance()
		particles.global_position = global_position
		particles.emitting = true
		get_tree().current_scene.add_child(particles)
		body.get_node("Camera").add_trauma(0.3)
		body.apply_damage(damage)
	queue_free()
