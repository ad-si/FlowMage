# Tests for the FlatCV GDExtension wrapper (addons/flatcv).
extends "res://tests/test_case.gd"

const L8 := Image.FORMAT_L8
const RGBA8 := Image.FORMAT_RGBA8


func _img(w := 8, h := 6) -> Image:
  var image := Image.create(w, h, false, RGBA8)
  image.fill(Color(0.6, 0.3, 0.1, 1.0))
  return image


func test_extension_registered() -> void:
  assert_true(ClassDB.class_exists("FlatCV"), "FlatCV class not registered")


func test_rgba_to_grayscale_is_l8() -> void:
  var out := FlatCV.rgba_to_grayscale(_img())
  assert_not_null(out)
  assert_eq(out.get_format(), L8)


func test_grayscale_is_rgba() -> void:
  assert_eq(FlatCV.grayscale(_img()).get_format(), RGBA8)


func test_sobel_is_l8() -> void:
  assert_eq(FlatCV.sobel_edge_detection(_img()).get_format(), L8)


func test_convert_to_binary_is_l8() -> void:
  assert_eq(FlatCV.convert_to_binary(_img(), "FFFFFF", "000000").get_format(), L8)


func test_single_to_multichannel_is_rgba() -> void:
  var gray := FlatCV.rgba_to_grayscale(_img())
  assert_eq(FlatCV.single_to_multichannel(gray).get_format(), RGBA8)


func test_transpose_swaps_dims() -> void:
  var out := FlatCV.transpose(_img(8, 6))
  assert_eq(out.get_width(), 6)
  assert_eq(out.get_height(), 8)


func test_rotate_90_swaps_dims() -> void:
  var out := FlatCV.rotate_90_cw(_img(8, 6))
  assert_eq(out.get_width(), 6)
  assert_eq(out.get_height(), 8)


func test_rotate_180_keeps_dims() -> void:
  var out := FlatCV.rotate_180(_img(8, 6))
  assert_eq(out.get_width(), 8)
  assert_eq(out.get_height(), 6)


func test_resize_scales_each_axis() -> void:
  var out := FlatCV.resize(_img(8, 6), 2.0, 0.5)
  assert_eq(out.get_width(), 16)
  assert_eq(out.get_height(), 3)


func test_crop_clamps_to_bounds() -> void:
  # Crop rect far larger than the image must clamp to what remains.
  var out := FlatCV.crop(_img(8, 6), 2, 2, 100, 100)
  assert_not_null(out)
  assert_eq(out.get_width(), 6)
  assert_eq(out.get_height(), 4)


func test_morphology_runs() -> void:
  var binary := FlatCV.otsu_threshold(_img(), false)
  assert_not_null(FlatCV.binary_dilation(binary, 2))
  assert_not_null(FlatCV.binary_erosion(binary, 2))
  assert_not_null(FlatCV.binary_opening(binary, 2))
  assert_not_null(FlatCV.binary_closing(binary, 2))


func test_histogram_runs() -> void:
  assert_not_null(FlatCV.histogram(_img()))


func test_gaussian_blur_preserves_size() -> void:
  var out := FlatCV.gaussian_blur(_img(8, 6), 2.0)
  assert_eq(out.get_width(), 8)
  assert_eq(out.get_height(), 6)
