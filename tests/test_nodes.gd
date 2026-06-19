# Tests for the graph node layer (GraphNodes/*.tscn + flow_node.gd).
extends "res://tests/test_case.gd"


func _img(w := 8, h := 6) -> Image:
  var image := Image.create(w, h, false, Image.FORMAT_RGBA8)
  image.fill(Color(0.6, 0.3, 0.1, 1.0))
  return image


# Instantiate a node scene and add it to the tree so `_ready` builds its UI.
func _spawn(scene_name: String):
  var scene: PackedScene = load("res://GraphNodes/%s.tscn" % scene_name)
  if scene == null:
    fail("could not load scene %s" % scene_name)
    return null
  var node = scene.instantiate()
  tree.root.add_child(node)
  await tree.process_frame
  return node


func _param_row_count(node) -> int:
  var rows := 0
  for child in node.get_children():
    if child is HBoxContainer:
      rows += 1
  return rows


func test_grayscale_outputs_l8() -> void:
  var node = await _spawn("Grayscale")
  var out = node.evaluate(_img())
  assert_not_null(out)
  assert_eq(out.get_format(), Image.FORMAT_L8)
  node.queue_free()


func test_gaussian_blur_builds_one_param() -> void:
  var node = await _spawn("GaussianBlur")
  assert_eq(_param_row_count(node), 1, "expected one Radius row")
  var out = node.evaluate(_img())
  assert_not_null(out)
  assert_eq(out.get_format(), Image.FORMAT_RGBA8)
  node.queue_free()


func test_convert_to_binary_builds_two_params() -> void:
  var node = await _spawn("ConvertToBinary")
  assert_eq(_param_row_count(node), 2, "expected foreground + background rows")
  node.queue_free()


func test_crop_clamps_to_image() -> void:
  # Default crop is 256x256; the result must clamp to the 8x6 input.
  var node = await _spawn("Crop")
  var out = node.evaluate(_img(8, 6))
  assert_not_null(out)
  assert_eq(out.get_width(), 8)
  assert_eq(out.get_height(), 6)
  node.queue_free()


func test_pass_through_returns_input_unchanged() -> void:
  var node = await _spawn("GaussianBlur")
  node.pass_through = true
  var src = _img()
  var out = node.evaluate(src)
  assert_same(out, src, "pass-through must return the very same image")
  node.queue_free()


func test_null_input_returns_null() -> void:
  var node = await _spawn("Sobel")
  assert_null(node.evaluate(null))
  node.queue_free()


func test_get_param_reads_default() -> void:
  var node = await _spawn("Resize")
  # Resize registers Scale X then Scale Y, both defaulting to 1.0.
  assert_eq(node.get_param(0), 1.0)
  assert_eq(node.get_param(1), 1.0)
  node.queue_free()
