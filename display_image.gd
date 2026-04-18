extends TextureRect

@onready var placeholder: Label = $Placeholder


func _ready():
  clear()


func clear():
  texture = null
  if placeholder:
    placeholder.visible = true


func render_image(image: Image):
  if image == null:
    clear()
    return
  texture = ImageTexture.create_from_image(image)
  if placeholder:
    placeholder.visible = false
