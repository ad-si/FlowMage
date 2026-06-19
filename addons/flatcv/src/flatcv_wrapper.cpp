#include "flatcv_wrapper.h"

#include <cstdlib>
#include <cstring>

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/packed_byte_array.hpp>

extern "C" {
#include "binary_closing_disk.h"
#include "conversion.h"
#include "convert_to_binary.h"
#include "crop.h"
#include "extract_document.h"
#include "flip.h"
#include "histogram.h"
#include "rgba_to_grayscale.h"
#include "rotate.h"
#include "single_to_multichannel.h"
#include "sobel_edge_detection.h"
#include "trim.h"
}

namespace godot {

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// Return an RGBA8 (4 bytes/px) copy of the input.
static Ref<Image> as_rgba8(const Ref<Image> &p_image) {
  Ref<Image> img = p_image->duplicate();
  if (img->get_format() != Image::FORMAT_RGBA8) {
    img->convert(Image::FORMAT_RGBA8);
  }
  return img;
}

// Return a single-channel L8 (1 byte/px) copy of the input.
static Ref<Image> as_l8(const Ref<Image> &p_image) {
  Ref<Image> img = p_image->duplicate();
  if (img->get_format() != Image::FORMAT_L8) {
    img->convert(Image::FORMAT_L8);
  }
  return img;
}

// Build an RGBA8 image from a malloc'd FlatCV buffer (4 bytes/px) and free it.
static Ref<Image> rgba_from_buffer(uint8_t *buffer, int width, int height) {
  if (buffer == nullptr) {
    return Ref<Image>();
  }
  const size_t size = (size_t)width * (size_t)height * 4;
  PackedByteArray bytes;
  bytes.resize((int64_t)size);
  std::memcpy(bytes.ptrw(), buffer, size);
  std::free(buffer);
  return Image::create_from_data(width, height, false, Image::FORMAT_RGBA8, bytes);
}

// Build an L8 image from a malloc'd FlatCV buffer (1 byte/px) and free it.
static Ref<Image> l8_from_buffer(uint8_t *buffer, int width, int height) {
  if (buffer == nullptr) {
    return Ref<Image>();
  }
  const size_t size = (size_t)width * (size_t)height;
  PackedByteArray bytes;
  bytes.resize((int64_t)size);
  std::memcpy(bytes.ptrw(), buffer, size);
  std::free(buffer);
  return Image::create_from_data(width, height, false, Image::FORMAT_L8, bytes);
}

#define FCV_CHECK_NULL(p_image) \
  ERR_FAIL_COND_V_MSG((p_image).is_null(), Ref<Image>(), "FlatCV: input image is null")

// ---------------------------------------------------------------------------
// Bindings
// ---------------------------------------------------------------------------

void FlatCV::_bind_methods() {
  ClassDB::bind_static_method("FlatCV", D_METHOD("rgba_to_grayscale", "image"), &FlatCV::rgba_to_grayscale);
  ClassDB::bind_static_method("FlatCV", D_METHOD("grayscale", "image"), &FlatCV::grayscale);
  ClassDB::bind_static_method("FlatCV", D_METHOD("grayscale_stretch", "image"), &FlatCV::grayscale_stretch);

  ClassDB::bind_static_method("FlatCV", D_METHOD("gaussian_blur", "image", "radius"), &FlatCV::gaussian_blur);
  ClassDB::bind_static_method("FlatCV", D_METHOD("sobel_edge_detection", "image"), &FlatCV::sobel_edge_detection);

  ClassDB::bind_static_method("FlatCV", D_METHOD("otsu_threshold", "image", "double_threshold"), &FlatCV::otsu_threshold);
  ClassDB::bind_static_method("FlatCV", D_METHOD("bw_smart", "image", "double_threshold"), &FlatCV::bw_smart);
  ClassDB::bind_static_method("FlatCV", D_METHOD("convert_to_binary", "image", "foreground_hex", "background_hex"), &FlatCV::convert_to_binary);

  ClassDB::bind_static_method("FlatCV", D_METHOD("binary_dilation", "image", "radius"), &FlatCV::binary_dilation);
  ClassDB::bind_static_method("FlatCV", D_METHOD("binary_erosion", "image", "radius"), &FlatCV::binary_erosion);
  ClassDB::bind_static_method("FlatCV", D_METHOD("binary_opening", "image", "radius"), &FlatCV::binary_opening);
  ClassDB::bind_static_method("FlatCV", D_METHOD("binary_closing", "image", "radius"), &FlatCV::binary_closing);

  ClassDB::bind_static_method("FlatCV", D_METHOD("flip_x", "image"), &FlatCV::flip_x);
  ClassDB::bind_static_method("FlatCV", D_METHOD("flip_y", "image"), &FlatCV::flip_y);
  ClassDB::bind_static_method("FlatCV", D_METHOD("transpose", "image"), &FlatCV::transpose);
  ClassDB::bind_static_method("FlatCV", D_METHOD("transverse", "image"), &FlatCV::transverse);
  ClassDB::bind_static_method("FlatCV", D_METHOD("rotate_90_cw", "image"), &FlatCV::rotate_90_cw);
  ClassDB::bind_static_method("FlatCV", D_METHOD("rotate_180", "image"), &FlatCV::rotate_180);
  ClassDB::bind_static_method("FlatCV", D_METHOD("rotate_270_cw", "image"), &FlatCV::rotate_270_cw);
  ClassDB::bind_static_method("FlatCV", D_METHOD("resize", "image", "scale_x", "scale_y"), &FlatCV::resize);
  ClassDB::bind_static_method("FlatCV", D_METHOD("crop", "image", "x", "y", "width", "height"), &FlatCV::crop);
  ClassDB::bind_static_method("FlatCV", D_METHOD("trim", "image"), &FlatCV::trim);
  ClassDB::bind_static_method("FlatCV", D_METHOD("trim_threshold", "image", "threshold_percent"), &FlatCV::trim_threshold);

  ClassDB::bind_static_method("FlatCV", D_METHOD("single_to_multichannel", "image"), &FlatCV::single_to_multichannel);

  ClassDB::bind_static_method("FlatCV", D_METHOD("extract_document", "image"), &FlatCV::extract_document);
  ClassDB::bind_static_method("FlatCV", D_METHOD("histogram", "image"), &FlatCV::histogram);
}

// ---------------------------------------------------------------------------
// Color / tone
// ---------------------------------------------------------------------------

Ref<Image> FlatCV::rgba_to_grayscale(const Ref<Image> &p_image) {
  FCV_CHECK_NULL(p_image);
  Ref<Image> rgba = as_rgba8(p_image);
  const int w = rgba->get_width();
  const int h = rgba->get_height();
  return l8_from_buffer(fcv_rgba_to_grayscale(w, h, rgba->get_data().ptr()), w, h);
}

Ref<Image> FlatCV::grayscale(const Ref<Image> &p_image) {
  FCV_CHECK_NULL(p_image);
  Ref<Image> rgba = as_rgba8(p_image);
  const int w = rgba->get_width();
  const int h = rgba->get_height();
  return rgba_from_buffer(fcv_grayscale(w, h, rgba->get_data().ptr()), w, h);
}

Ref<Image> FlatCV::grayscale_stretch(const Ref<Image> &p_image) {
  FCV_CHECK_NULL(p_image);
  Ref<Image> rgba = as_rgba8(p_image);
  const int w = rgba->get_width();
  const int h = rgba->get_height();
  return rgba_from_buffer(fcv_grayscale_stretch(w, h, rgba->get_data().ptr()), w, h);
}

// ---------------------------------------------------------------------------
// Filters
// ---------------------------------------------------------------------------

Ref<Image> FlatCV::gaussian_blur(const Ref<Image> &p_image, double p_radius) {
  FCV_CHECK_NULL(p_image);
  Ref<Image> rgba = as_rgba8(p_image);
  const int w = rgba->get_width();
  const int h = rgba->get_height();
  return rgba_from_buffer(fcv_apply_gaussian_blur(w, h, p_radius, rgba->get_data().ptr()), w, h);
}

Ref<Image> FlatCV::sobel_edge_detection(const Ref<Image> &p_image) {
  FCV_CHECK_NULL(p_image);
  Ref<Image> rgba = as_rgba8(p_image);
  const int w = rgba->get_width();
  const int h = rgba->get_height();
  return l8_from_buffer(fcv_sobel_edge_detection(w, h, 4, rgba->get_data().ptr()), w, h);
}

// ---------------------------------------------------------------------------
// Threshold / binarize
// ---------------------------------------------------------------------------

Ref<Image> FlatCV::otsu_threshold(const Ref<Image> &p_image, bool p_double_threshold) {
  FCV_CHECK_NULL(p_image);
  Ref<Image> rgba = as_rgba8(p_image);
  const int w = rgba->get_width();
  const int h = rgba->get_height();
  return rgba_from_buffer(fcv_otsu_threshold_rgba(w, h, p_double_threshold, rgba->get_data().ptr()), w, h);
}

Ref<Image> FlatCV::bw_smart(const Ref<Image> &p_image, bool p_double_threshold) {
  FCV_CHECK_NULL(p_image);
  Ref<Image> rgba = as_rgba8(p_image);
  const int w = rgba->get_width();
  const int h = rgba->get_height();
  return rgba_from_buffer(fcv_bw_smart(w, h, p_double_threshold, rgba->get_data().ptr()), w, h);
}

Ref<Image> FlatCV::convert_to_binary(
  const Ref<Image> &p_image,
  const String &p_foreground_hex,
  const String &p_background_hex
) {
  FCV_CHECK_NULL(p_image);
  Ref<Image> rgba = as_rgba8(p_image);
  const int w = rgba->get_width();
  const int h = rgba->get_height();
  const CharString fg = p_foreground_hex.utf8();
  const CharString bg = p_background_hex.utf8();
  uint8_t *out = fcv_convert_to_binary(rgba->get_data().ptr(), w, h, fg.get_data(), bg.get_data());
  return l8_from_buffer(out, w, h);
}

// ---------------------------------------------------------------------------
// Binary morphology
// ---------------------------------------------------------------------------

Ref<Image> FlatCV::binary_dilation(const Ref<Image> &p_image, int p_radius) {
  FCV_CHECK_NULL(p_image);
  Ref<Image> gray = as_l8(p_image);
  const int w = gray->get_width();
  const int h = gray->get_height();
  return l8_from_buffer(fcv_binary_dilation_disk(gray->get_data().ptr(), w, h, p_radius), w, h);
}

Ref<Image> FlatCV::binary_erosion(const Ref<Image> &p_image, int p_radius) {
  FCV_CHECK_NULL(p_image);
  Ref<Image> gray = as_l8(p_image);
  const int w = gray->get_width();
  const int h = gray->get_height();
  return l8_from_buffer(fcv_binary_erosion_disk(gray->get_data().ptr(), w, h, p_radius), w, h);
}

Ref<Image> FlatCV::binary_opening(const Ref<Image> &p_image, int p_radius) {
  FCV_CHECK_NULL(p_image);
  Ref<Image> gray = as_l8(p_image);
  const int w = gray->get_width();
  const int h = gray->get_height();
  return l8_from_buffer(fcv_binary_opening_disk(gray->get_data().ptr(), w, h, p_radius), w, h);
}

Ref<Image> FlatCV::binary_closing(const Ref<Image> &p_image, int p_radius) {
  FCV_CHECK_NULL(p_image);
  Ref<Image> gray = as_l8(p_image);
  const int w = gray->get_width();
  const int h = gray->get_height();
  return l8_from_buffer(fcv_binary_closing_disk(gray->get_data().ptr(), w, h, p_radius), w, h);
}

// ---------------------------------------------------------------------------
// Geometry
// ---------------------------------------------------------------------------

Ref<Image> FlatCV::flip_x(const Ref<Image> &p_image) {
  FCV_CHECK_NULL(p_image);
  Ref<Image> rgba = as_rgba8(p_image);
  const int w = rgba->get_width();
  const int h = rgba->get_height();
  return rgba_from_buffer(fcv_flip_x(w, h, rgba->get_data().ptr()), w, h);
}

Ref<Image> FlatCV::flip_y(const Ref<Image> &p_image) {
  FCV_CHECK_NULL(p_image);
  Ref<Image> rgba = as_rgba8(p_image);
  const int w = rgba->get_width();
  const int h = rgba->get_height();
  return rgba_from_buffer(fcv_flip_y(w, h, rgba->get_data().ptr()), w, h);
}

Ref<Image> FlatCV::transpose(const Ref<Image> &p_image) {
  FCV_CHECK_NULL(p_image);
  Ref<Image> rgba = as_rgba8(p_image);
  const int w = rgba->get_width();
  const int h = rgba->get_height();
  // Transpose swaps the image dimensions.
  return rgba_from_buffer(fcv_transpose(w, h, rgba->get_data().ptr()), h, w);
}

Ref<Image> FlatCV::transverse(const Ref<Image> &p_image) {
  FCV_CHECK_NULL(p_image);
  Ref<Image> rgba = as_rgba8(p_image);
  const int w = rgba->get_width();
  const int h = rgba->get_height();
  return rgba_from_buffer(fcv_transverse(w, h, rgba->get_data().ptr()), h, w);
}

Ref<Image> FlatCV::rotate_90_cw(const Ref<Image> &p_image) {
  FCV_CHECK_NULL(p_image);
  Ref<Image> rgba = as_rgba8(p_image);
  const int w = rgba->get_width();
  const int h = rgba->get_height();
  return rgba_from_buffer(fcv_rotate_90_cw(w, h, rgba->get_data().ptr()), h, w);
}

Ref<Image> FlatCV::rotate_180(const Ref<Image> &p_image) {
  FCV_CHECK_NULL(p_image);
  Ref<Image> rgba = as_rgba8(p_image);
  const int w = rgba->get_width();
  const int h = rgba->get_height();
  return rgba_from_buffer(fcv_rotate_180(w, h, rgba->get_data().ptr()), w, h);
}

Ref<Image> FlatCV::rotate_270_cw(const Ref<Image> &p_image) {
  FCV_CHECK_NULL(p_image);
  Ref<Image> rgba = as_rgba8(p_image);
  const int w = rgba->get_width();
  const int h = rgba->get_height();
  return rgba_from_buffer(fcv_rotate_270_cw(w, h, rgba->get_data().ptr()), h, w);
}

Ref<Image> FlatCV::resize(const Ref<Image> &p_image, double p_scale_x, double p_scale_y) {
  FCV_CHECK_NULL(p_image);
  Ref<Image> rgba = as_rgba8(p_image);
  const int w = rgba->get_width();
  const int h = rgba->get_height();
  uint32_t out_w = 0;
  uint32_t out_h = 0;
  uint8_t *out = fcv_resize(w, h, p_scale_x, p_scale_y, &out_w, &out_h, rgba->get_data().ptr());
  return rgba_from_buffer(out, (int)out_w, (int)out_h);
}

Ref<Image> FlatCV::crop(const Ref<Image> &p_image, int p_x, int p_y, int p_width, int p_height) {
  FCV_CHECK_NULL(p_image);
  Ref<Image> rgba = as_rgba8(p_image);
  const int w = rgba->get_width();
  const int h = rgba->get_height();

  // Clamp the crop rectangle into the image so fcv_crop never rejects it.
  int x = CLAMP(p_x, 0, w - 1);
  int y = CLAMP(p_y, 0, h - 1);
  int cw = CLAMP(p_width, 1, w - x);
  int ch = CLAMP(p_height, 1, h - y);

  uint8_t *out = fcv_crop(w, h, 4, rgba->get_data().ptr(), x, y, cw, ch);
  return rgba_from_buffer(out, cw, ch);
}

Ref<Image> FlatCV::trim(const Ref<Image> &p_image) {
  FCV_CHECK_NULL(p_image);
  Ref<Image> rgba = as_rgba8(p_image);
  int w = rgba->get_width();
  int h = rgba->get_height();
  uint8_t *out = fcv_trim(&w, &h, 4, rgba->get_data().ptr());
  return rgba_from_buffer(out, w, h);
}

Ref<Image> FlatCV::trim_threshold(const Ref<Image> &p_image, double p_threshold_percent) {
  FCV_CHECK_NULL(p_image);
  Ref<Image> rgba = as_rgba8(p_image);
  int w = rgba->get_width();
  int h = rgba->get_height();
  uint8_t *out = fcv_trim_threshold(&w, &h, 4, rgba->get_data().ptr(), p_threshold_percent);
  return rgba_from_buffer(out, w, h);
}

// ---------------------------------------------------------------------------
// Channels
// ---------------------------------------------------------------------------

Ref<Image> FlatCV::single_to_multichannel(const Ref<Image> &p_image) {
  FCV_CHECK_NULL(p_image);
  Ref<Image> gray = as_l8(p_image);
  const int w = gray->get_width();
  const int h = gray->get_height();
  return rgba_from_buffer(fcv_single_to_multichannel(w, h, gray->get_data().ptr()), w, h);
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

Ref<Image> FlatCV::extract_document(const Ref<Image> &p_image) {
  FCV_CHECK_NULL(p_image);
  Ref<Image> rgba = as_rgba8(p_image);
  const int w = rgba->get_width();
  const int h = rgba->get_height();
  uint32_t out_w = 0;
  uint32_t out_h = 0;
  uint8_t *out = fcv_extract_document_auto(w, h, rgba->get_data().ptr(), &out_w, &out_h);
  return rgba_from_buffer(out, (int)out_w, (int)out_h);
}

// ---------------------------------------------------------------------------
// Analysis
// ---------------------------------------------------------------------------

Ref<Image> FlatCV::histogram(const Ref<Image> &p_image) {
  FCV_CHECK_NULL(p_image);
  Ref<Image> rgba = as_rgba8(p_image);
  const int w = rgba->get_width();
  const int h = rgba->get_height();
  uint32_t out_w = 0;
  uint32_t out_h = 0;
  uint8_t *out = fcv_generate_histogram(w, h, 4, rgba->get_data().ptr(), &out_w, &out_h);
  return rgba_from_buffer(out, (int)out_w, (int)out_h);
}

} // namespace godot
