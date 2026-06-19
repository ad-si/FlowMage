extends "res://GraphNodes/flow_node.gd"


func _evaluate_internal(input):
  if input == null:
    return null
  return FlatCV.trim(input)


func get_documentation() -> String:
  return """Trim

Trims uniform-coloured border pixels.

Input: RGBA  Output: RGBA"""
