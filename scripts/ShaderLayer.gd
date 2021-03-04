tool
extends TextureRect

export(float, 0.0, 3.0, 0.1) var duration : float = 1.0
export(float, 0.0, 1.0) var fill : float = 0.0 setget _set_fill

var tween_lock : bool = false

onready var tween : Tween = $Tween

func show_screen() -> void:
	if tween_lock or fill == 0.0:
		return
	tween_lock = true
	if tween.interpolate_property(self, "fill", fill, 0.0, duration*(fill),
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT):
		if tween.start():
			yield(tween, "tween_completed")
			tween_lock = false
	
func hide_screen() -> void:
	if tween_lock or fill == 1.0:
		return
	tween_lock = true
	if tween.interpolate_property(self, "fill", fill, 1.0, duration*(1.0-fill),
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT):
		if tween.start():
			yield(tween, "tween_completed")
			tween_lock = false

func _set_fill(val:float) -> void:
	fill = clamp(val, 0.0, 1.0)
	material.set_shader_param("fill", fill)
