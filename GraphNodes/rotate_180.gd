extends "res://GraphNodes/flow_node.gd"


func _evaluate_internal(input):
  if input == null:
    return null
  return FlatCV.rotate_180(input)


func get_documentation() -> String:
  return """Rotate 180

Rotates the image 180 degrees.

Input: RGBA  Output: RGBA"""
