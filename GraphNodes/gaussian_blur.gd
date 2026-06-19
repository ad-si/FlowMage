extends "res://GraphNodes/flow_node.gd"


func _ready() -> void:
  super()
  add_param_number("Radius", 3.0, 0.0, 1000.0, 1.0)


func _evaluate_internal(input):
  if input == null:
    return null
  return FlatCV.gaussian_blur(input, get_param(0))


func get_documentation() -> String:
  return """Gaussian Blur

Applies a separable Gaussian blur with the given radius (sigma = radius / 3).

Input: RGBA  Output: RGBA"""
