extends "res://GraphNodes/flow_node.gd"


func _evaluate_internal(input):
  if input == null:
    return null
  return FlatCV.grayscale_stretch(input)


func get_documentation() -> String:
  return """Grayscale Stretch

Converts to grayscale and stretches contrast so the darkest ~1.5% of pixels become black and the brightest ~1.5% become white, scaling the rest linearly.

Input: RGBA  Output: RGBA"""
