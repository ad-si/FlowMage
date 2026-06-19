extends "res://GraphNodes/flow_node.gd"


func _ready() -> void:
  super()
  add_param_number("Threshold %", 2.0, 0.0, 100.0, 0.5)


func _evaluate_internal(input):
  if input == null:
    return null
  return FlatCV.trim_threshold(input, get_param(0))


func get_documentation() -> String:
  return """Trim Threshold

Trims border pixels within the given percentage tolerance of the corner colour. Useful for JPEG artefacts or vignetting.

Input: RGBA  Output: RGBA"""
