extends "res://GraphNodes/flow_node.gd"


func _evaluate_internal(input):
  if input == null:
    return null
  return FlatCV.flip_x(input)


func get_documentation() -> String:
  return """Flip Horizontal

Mirrors the image along the vertical axis.

Input: RGBA  Output: RGBA"""
