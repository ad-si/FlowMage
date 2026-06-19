extends "res://GraphNodes/flow_node.gd"


func _ready() -> void:
  super()
  add_param_bool("Double", false)


func _evaluate_internal(input):
  if input == null:
    return null
  return FlatCV.bw_smart(input, get_param(0))


func get_documentation() -> String:
  return """BW Smart

Adaptive black & white: subtracts a blurred copy to isolate high frequencies, then applies an Otsu threshold. Good for documents.

Input: RGBA  Output: RGBA (black/white)"""
