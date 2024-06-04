extends TextureRect

func _ready():
	render_image("res://photo.jpeg")

func render_image(path: String):
	self.texture = load(path)
