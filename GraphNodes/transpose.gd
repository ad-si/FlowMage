extends "res://GraphNodes/flow_node.gd"


func _evaluate_internal(input):
  if input == null:
    return null
  return FlatCV.transpose(input)


func get_documentation() -> String:
  return """Transpose

Transposes the image (flips across the main diagonal). Swaps width and height.

Input: RGBA  Output: RGBA"""
