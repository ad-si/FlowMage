extends "res://GraphNodes/flow_node.gd"


func _evaluate_internal(input):
  if input == null:
    return null
  return FlatCV.transverse(input)


func get_documentation() -> String:
  return """Transverse

Flips the image across the anti-diagonal. Swaps width and height.

Input: RGBA  Output: RGBA"""
