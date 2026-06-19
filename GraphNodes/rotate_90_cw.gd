extends "res://GraphNodes/flow_node.gd"


func _evaluate_internal(input):
  if input == null:
    return null
  return FlatCV.rotate_90_cw(input)


func get_documentation() -> String:
  return """Rotate 90 CW

Rotates the image 90 degrees clockwise. Swaps width and height.

Input: RGBA  Output: RGBA"""
