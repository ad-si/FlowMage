extends "res://GraphNodes/flow_node.gd"


func _evaluate_internal(input):
  if input == null:
    return null
  return FlatCV.sobel_edge_detection(input)


func get_documentation() -> String:
  return """Sobel Edges

Sobel edge detection. Computes the gradient magnitude and normalises it to 0-255.

Input: RGBA  Output: grayscale"""
