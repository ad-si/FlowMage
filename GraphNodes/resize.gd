extends "res://GraphNodes/flow_node.gd"


func _ready() -> void:
  super()
  add_param_number("Scale X", 1.0, 0.05, 20.0, 0.05)
  add_param_number("Scale Y", 1.0, 0.05, 20.0, 0.05)


func _evaluate_internal(input):
  if input == null:
    return null
  return FlatCV.resize(input, get_param(0), get_param(1))


func get_documentation() -> String:
  return """Resize

Resizes by the given scale factors using area averaging (downscale) or bilinear interpolation (upscale).

Input: RGBA  Output: RGBA"""
