extends "res://GraphNodes/flow_node.gd"


func _evaluate_internal(input):
  if input == null:
    return null
  return FlatCV.rgba_to_grayscale(input)


func get_documentation() -> String:
  return (
    "Grayscale\n\n"
    + "Converts an RGBA image to a single-channel grayscale image "
    + "using the FlatCV extension.\n\n"
    + "Input: RGBA image\n"
    + "Output: Grayscale image"
  )
