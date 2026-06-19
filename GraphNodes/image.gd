extends "res://GraphNodes/flow_node.gd"

var current_path := ""


func set_loaded_path(new_path):
  current_path = new_path
  $LineEdit.set_text(new_path)


func _evaluate_internal(_input):
  if current_path == "":
    return null
  var image := Image.load_from_file(current_path)
  if image == null:
    push_warning("Failed to load image: %s" % current_path)
  return image


func _on_Button_pressed():
  var fileDialog := FileDialog.new()
  fileDialog.title = "Select An Image"
  fileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
  fileDialog.access = FileDialog.ACCESS_FILESYSTEM
  fileDialog.use_native_dialog = true
  fileDialog.filters = PackedStringArray(
    [
      "*.png,*.jpg,*.jpeg,*.webp,*.bmp,*.gif,*.tga,*.svg ; Images",
    ]
  )
  fileDialog.connect("file_selected", Callable(self, "on_file_selected"))

  add_child(fileDialog)
  fileDialog.popup(Rect2(100, 100, 700, 500))


func on_file_selected(filePath: String):
  current_path = filePath
  $LineEdit.set_text(filePath)
  var graph := get_parent()
  if graph and graph.has_method("trigger_image_synthesis"):
    graph.trigger_image_synthesis()


func get_documentation() -> String:
  return (
    "Image\n\n"
    + "Loads an image from a file on disk.\n\n"
    + "Click 'Select Image' to choose a file. "
    + "Supported formats: PNG, JPG, WEBP, BMP, GIF, TGA, SVG.\n\n"
    + "Output: RGBA image"
  )
