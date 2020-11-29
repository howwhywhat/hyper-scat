tool
extends CanvasLayer

var transition_list : Array = [
	"transition-hbars.png",
	"transition-vbars.png",
	"transition-mechadoor.png",
	"transition-noise.png",
	"transition-motion.png",
	"transition-motion-pixel.png",
	"transition-swirl.png",
	"transition-pixel-swirl.png",
	"transition-pixel.png",
	"transition-slashes.png",
	"transition-stripes.png",
	"transition-grid.png"
]

enum Transitions {
	bars_x,
	bars_y,
	mecha_door,
	noise,
	motion,
	motion_pixel,
	swirl,
	pixel_swirl_2,
	pixel_swirl,
	slashes,
	stripes,
	grid
}

export(Transitions) var mask : int = 0 setget _set_mask
export(float, 0.0, 1.0) var fill : float = 0 setget _set_fill
export(float, 0.0, 3.0, 0.1) var duration : float = 1 setget _set_duration

var input_lock : bool = false

onready var shaderLayer : TextureRect = $ShaderLayer

func _ready():
	self.mask = mask
	self.fill = fill
	self.duration = duration
	
func _set_mask(transition_mask:int):
	var new_mask : Texture = load(
		"res://assets/textures/transitions/%s" %
		transition_list[transition_mask])
	if new_mask:
		mask = transition_mask
		if Engine.editor_hint:
			$ShaderLayer.texture = new_mask
		elif shaderLayer:
			shaderLayer.texture = new_mask

func _set_fill(val:float):
	fill = val
	if Engine.editor_hint:
		$ShaderLayer.fill = val
	elif shaderLayer:
		shaderLayer.fill = val

func _set_duration(val:float):
	duration = val
	if Engine.editor_hint:
		$ShaderLayer.duration = val
	elif shaderLayer:
		shaderLayer.duration = val
