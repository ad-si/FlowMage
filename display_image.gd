extends TextureRect

func _ready():
	var texture = ImageTexture.new()
	var image = Image.new()
	image.load("res://photo.jpeg")
	texture.create_from_image(image)
	self.texture = texture
