extends Sprite

class_name Paint

var surface_image : Image = Image.new()
var surface_texture : ImageTexture = ImageTexture.new()
var blood_texture : ImageTexture = ImageTexture.new()
var blood_image : Image = Image.new()

func _ready() -> void:
	surface_image.create(1500, 1000, false, Image.FORMAT_RGBAH)
	surface_image.fill(Color(0,0,0,0))
	surface_texture.create_from_image(surface_image)
	
	blood_image.load("res://assets/textures/particles/blood1.png")
	blood_image.convert(Image.FORMAT_RGBAH)
	blood_texture.create_from_image(blood_image)
	
	texture = surface_texture

func draw_blood(draw_pos : Vector2):
	surface_image.lock()
	surface_image.blit_rect(blood_image, Rect2(Vector2(0,0), Vector2(3,3)), draw_pos)
	surface_image.unlock()
	pass

func _physics_process(delta : float) -> void:
	surface_texture.create_from_image(surface_image)
