extends "res://GraphNodes/flow_node.gd"


func _ready() -> void:
  super()
  add_param_number("X", 0.0, 0.0, 100000.0, 1.0)
  add_param_number("Y", 0.0, 0.0, 100000.0, 1.0)
  add_param_number("Width", 256.0, 1.0, 100000.0, 1.0)
  add_param_number("Height", 256.0, 1.0, 100000.0, 1.0)


func _evaluate_internal(input):
  if input == null:
    return null
  return FlatCV.crop(
    input, int(get_param(0)), int(get_param(1)), int(get_param(2)), int(get_param(3))
  )


func get_documentation() -> String:
  return """Crop

Crops a rectangle from the image. The rectangle is clamped to stay inside the image bounds.

Input: RGBA  Output: RGBA"""
