extends TextureRect

const FlowSpinner := preload("res://GraphNodes/spinner.gd")

@onready var placeholder: Label = $Placeholder
var _spinner: Control = null


func _ready():
  _spinner = FlowSpinner.new()
  _spinner.custom_minimum_size = Vector2(56, 56)
  _spinner.line_width = 4.0
  add_child(_spinner)
  _spinner.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
  clear()


func clear():
  texture = null
  if placeholder:
    placeholder.visible = true
  hide_spinner()


func show_spinner():
  if _spinner:
    _spinner.set_spinning(true)
  if placeholder:
    placeholder.visible = false


func hide_spinner():
  if _spinner:
    _spinner.set_spinning(false)


func render_image(image: Image):
  hide_spinner()
  if image == null:
    clear()
    return
  texture = ImageTexture.create_from_image(image)
  if placeholder:
    placeholder.visible = false
