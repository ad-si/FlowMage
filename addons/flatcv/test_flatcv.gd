extends SceneTree


func _check(name: String, img: Image) -> bool:
  if img == null:
    push_error("%s returned null" % name)
    return false
  print("OK %s -> %dx%d fmt=%d" % [name, img.get_width(), img.get_height(), img.get_format()])
  return true


func _init():
  if not ClassDB.class_exists("FlatCV"):
    push_error("FlatCV class not registered")
    quit(1)
    return

  var img := Image.create(8, 6, false, Image.FORMAT_RGBA8)
  img.fill(Color(0.6, 0.3, 0.1, 1.0))

  var ok := true
  ok = _check("rgba_to_grayscale", FlatCV.rgba_to_grayscale(img)) and ok
  ok = _check("grayscale", FlatCV.grayscale(img)) and ok
  ok = _check("grayscale_stretch", FlatCV.grayscale_stretch(img)) and ok
  ok = _check("gaussian_blur", FlatCV.gaussian_blur(img, 2.0)) and ok
  ok = _check("sobel_edge_detection", FlatCV.sobel_edge_detection(img)) and ok
  ok = _check("otsu_threshold", FlatCV.otsu_threshold(img, false)) and ok
  ok = _check("bw_smart", FlatCV.bw_smart(img, false)) and ok
  ok = _check("convert_to_binary", FlatCV.convert_to_binary(img, "FFFFFF", "000000")) and ok

  var bin := FlatCV.otsu_threshold(img, false)
  ok = _check("binary_dilation", FlatCV.binary_dilation(bin, 2)) and ok
  ok = _check("binary_erosion", FlatCV.binary_erosion(bin, 2)) and ok
  ok = _check("binary_opening", FlatCV.binary_opening(bin, 2)) and ok
  ok = _check("binary_closing", FlatCV.binary_closing(bin, 2)) and ok

  ok = _check("flip_x", FlatCV.flip_x(img)) and ok
  ok = _check("flip_y", FlatCV.flip_y(img)) and ok
  ok = _check("transpose", FlatCV.transpose(img)) and ok
  ok = _check("transverse", FlatCV.transverse(img)) and ok
  ok = _check("rotate_90_cw", FlatCV.rotate_90_cw(img)) and ok
  ok = _check("rotate_180", FlatCV.rotate_180(img)) and ok
  ok = _check("rotate_270_cw", FlatCV.rotate_270_cw(img)) and ok
  ok = _check("resize", FlatCV.resize(img, 2.0, 0.5)) and ok
  ok = _check("crop", FlatCV.crop(img, 1, 1, 4, 3)) and ok
  ok = _check("trim", FlatCV.trim(img)) and ok
  ok = _check("trim_threshold", FlatCV.trim_threshold(img, 2.0)) and ok

  ok = (
    _check("single_to_multichannel", FlatCV.single_to_multichannel(FlatCV.rgba_to_grayscale(img)))
    and ok
  )
  ok = _check("histogram", FlatCV.histogram(img)) and ok

  # extract_document may legitimately fail to find a document in a flat image;
  # only assert it does not crash.
  var doc := FlatCV.extract_document(img)
  if doc != null:
    print("OK extract_document -> %dx%d" % [doc.get_width(), doc.get_height()])
  else:
    print("OK extract_document -> null (no document detected)")

  # Transpose must swap dimensions.
  var t := FlatCV.transpose(img)
  if t != null and (t.get_width() != 6 or t.get_height() != 8):
    push_error("transpose did not swap dimensions")
    ok = false

  if ok:
    print("ALL OK")
    quit(0)
  else:
    quit(1)
