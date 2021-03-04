tool
extends TextureProgress

var health := max_value

onready var tween : Tween = $Tween

func initialize(current, maximum) -> void:
	max_value = maximum
	value = current

func _process(_delta) -> void:
	value = health
	if health <= 0:
		get_parent().get_node("HealthText").text = "Health: 0/" + str(max_value)
	else:
		get_parent().get_node("HealthText").text = "Health: " + str(round(health)) + "/" + str(max_value)

func _on_Player_damage(damage : float) -> void:
	tween.interpolate_property(self, "health", health, damage, 1.0, Tween.TRANS_SINE, Tween.EASE_OUT)
	if not tween.is_active():
		tween.start()
	yield(tween, "tween_completed")
