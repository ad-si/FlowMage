extends "res://GraphNodes/flow_node.gd"


func _evaluate_internal(input):
  if input == null:
    return null
  return FlatCV.histogram(input)


func get_documentation() -> String:
  return """Histogram

Generates a histogram visualisation of the image's channel value distribution.

Input: RGBA  Output: RGBA (plot)"""
