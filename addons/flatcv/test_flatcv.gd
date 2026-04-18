extends SceneTree


func _init():
  if not ClassDB.class_exists("FlatCV"):
    push_error("FlatCV class not registered")
    quit(1)
    return
  var img := Image.create(4, 2, false, Image.FORMAT_RGBA8)
  img.fill(Color(0.6, 0.3, 0.1, 1.0))
  var gray: Image = FlatCV.rgba_to_grayscale(img)
  if gray == null:
    push_error("rgba_to_grayscale returned null")
    quit(1)
    return
  print(
    (
      "OK "
      + str(gray.get_width())
      + "x"
      + str(gray.get_height())
      + " fmt="
      + str(gray.get_format())
      + " px0="
      + str(gray.get_pixel(0, 0).r8)
    )
  )
  quit(0)
