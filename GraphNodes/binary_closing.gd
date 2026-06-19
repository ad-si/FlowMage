extends "res://GraphNodes/flow_node.gd"


func _ready() -> void:
  super()
  add_param_number("Radius", 3.0, 1.0, 50.0, 1.0)


func _evaluate_internal(input):
  if input == null:
    return null
  return FlatCV.binary_closing(input, int(get_param(0)))


func get_documentation() -> String:
  return """Close

Binary closing (dilation then erosion). Fills small black holes.

Input: binary grayscale  Output: binary grayscale"""
