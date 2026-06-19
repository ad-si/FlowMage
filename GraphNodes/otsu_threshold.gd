extends "res://GraphNodes/flow_node.gd"


func _ready() -> void:
  super()
  add_param_bool("Double", false)


func _evaluate_internal(input):
  if input == null:
    return null
  return FlatCV.otsu_threshold(input, get_param(0))


func get_documentation() -> String:
  return """Otsu Threshold

Binarises the image using Otsu's automatic threshold. Enable 'Double' for a soft band around the threshold instead of a hard cut.

Input: RGBA  Output: RGBA (black/white)"""
