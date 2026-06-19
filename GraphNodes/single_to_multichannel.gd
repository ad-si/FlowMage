extends "res://GraphNodes/flow_node.gd"


func _evaluate_internal(input):
  if input == null:
    return null
  return FlatCV.single_to_multichannel(input)


func get_documentation() -> String:
  return """To Multichannel

Expands a single-channel grayscale image to RGBA by copying the value into R, G and B.

Input: grayscale  Output: RGBA"""
