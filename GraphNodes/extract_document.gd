extends "res://GraphNodes/flow_node.gd"


func _evaluate_internal(input):
  if input == null:
    return null
  return FlatCV.extract_document(input)


func get_documentation() -> String:
  return """Extract Document

Detects a document's corners and applies a perspective transform to produce a flattened, deskewed image.

Input: RGBA  Output: RGBA"""
