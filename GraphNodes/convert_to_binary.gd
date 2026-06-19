extends "res://GraphNodes/flow_node.gd"


func _ready() -> void:
  super()
  add_param_text("Foreground", "FFFFFF")
  add_param_text("Background", "000000")


func _evaluate_internal(input):
  if input == null:
    return null
  return FlatCV.convert_to_binary(input, get_param(0), get_param(1))


func get_documentation() -> String:
  return """Convert To Binary

Maps the foreground hex colour to white and everything else to black.

Input: RGBA  Output: grayscale (binary)"""
