extends "res://GraphNodes/flow_node.gd"


func _evaluate_internal(input):
  if input == null:
    return null
  return FlatCV.rotate_270_cw(input)


func get_documentation() -> String:
  return """Rotate 270 CW

Rotates the image 270 degrees clockwise (90 counter-clockwise). Swaps width and height.

Input: RGBA  Output: RGBA"""
