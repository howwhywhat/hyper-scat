extends Enemy

var wake_up_animation_completed = false
var allow_shooting = false

onready var sleepingParticles := $SleepingParticles
onready var state := $State
onready var sprite := $Texture
onready var spriteHalf := $Texture2

onready var animation := $Animation
onready var weaponAnimation := $WeaponAnimation
onready var flashAnimation := $BlinkAnimation

onready var playerDetection := $PlayerDetection

var number_of_shots : int = 25
const BULLET_SCENE := preload("res://scenes/attacks/EnergyBall.tscn")
var can_fire : bool = true
onready var pivot := $Pivot
onready var bulletPosition := $Pivot/BulletPosition

func shoot() -> void:
	if allow_shooting and can_fire:
		player.lastHitEntity = self
		for shot in number_of_shots:
			var bullet := BULLET_SCENE.instance()
			pivot.rotation += (4 * PI / number_of_shots)
			bullet.global_position = bulletPosition.global_position
			bullet.rotation = pivot.rotation
			get_tree().current_scene.add_child(bullet)
			yield(get_tree().create_timer(.002), "timeout")
		can_fire = false
		yield(get_tree().create_timer(1.5), "timeout")
		can_fire = true

func _on_WeaponAnimation_animation_finished(anim_name : String) -> void:
	if anim_name == "wake_up":
		wake_up_animation_completed = true
		allow_shooting = true
		yield(get_tree().create_timer(0.4), "timeout")
		wake_up_animation_completed = false
	if anim_name == "asleep" and HEALTH <= 0:
		animation.play("death")

func damage(value : float) -> void:
	player.get_node("Camera").add_trauma(0.3)
	HEALTH -= value

func _on_Animation_animation_finished(anim_name : String) -> void:
	if anim_name == "death":
		queue_free()

func pounced(bouncer):
	damage(9999)
	bouncer.bounce()
