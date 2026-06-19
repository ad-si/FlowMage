extends "res://GraphNodes/flow_node.gd"


func _evaluate_internal(input):
  if input == null:
    return null
  return FlatCV.flip_y(input)


func get_documentation() -> String:
  return """Flip Vertical

Mirrors the image along the horizontal axis.

Input: RGBA  Output: RGBA"""
