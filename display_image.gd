extends TextureRect

@onready var placeholder: Label = $Placeholder


func _ready():
  clear()


func clear():
  texture = null
  if placeholder:
    placeholder.visible = true


func render_image(path: String):
  var image := Image.load_from_file(path)
  if image == null:
    push_warning("Failed to load image: %s" % path)
    clear()
    return
  texture = ImageTexture.create_from_image(image)
  if placeholder:
    placeholder.visible = false
