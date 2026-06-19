extends "res://GraphNodes/flow_node.gd"


func _ready() -> void:
  super()
  add_param_number("Radius", 3.0, 1.0, 50.0, 1.0)


func _evaluate_internal(input):
  if input == null:
    return null
  return FlatCV.binary_dilation(input, int(get_param(0)))


func get_documentation() -> String:
  return """Dilate

Binary morphological dilation with a disk of the given radius. Grows white (255) regions.

Input: binary grayscale  Output: binary grayscale"""
