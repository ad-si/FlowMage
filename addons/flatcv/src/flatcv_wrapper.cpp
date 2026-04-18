#include "flatcv_wrapper.h"

#include <cstdlib>
#include <cstring>

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/packed_byte_array.hpp>

extern "C" {
#include "rgba_to_grayscale.h"
}

namespace godot {

void FlatCV::_bind_methods() {
  ClassDB::bind_static_method(
    "FlatCV",
    D_METHOD("rgba_to_grayscale", "image"),
    &FlatCV::rgba_to_grayscale
  );
}

Ref<Image> FlatCV::rgba_to_grayscale(const Ref<Image> &p_image) {
  ERR_FAIL_COND_V_MSG(p_image.is_null(), Ref<Image>(), "FlatCV: input image is null");

  Ref<Image> rgba = p_image->duplicate();
  if (rgba->get_format() != Image::FORMAT_RGBA8) {
    rgba->convert(Image::FORMAT_RGBA8);
  }

  const uint32_t width = (uint32_t)rgba->get_width();
  const uint32_t height = (uint32_t)rgba->get_height();
  PackedByteArray rgba_bytes = rgba->get_data();

  uint8_t *gray = fcv_rgba_to_grayscale(width, height, rgba_bytes.ptr());
  ERR_FAIL_NULL_V_MSG(gray, Ref<Image>(), "FlatCV: fcv_rgba_to_grayscale returned null");

  const size_t gray_size = (size_t)width * (size_t)height;
  PackedByteArray gray_bytes;
  gray_bytes.resize((int64_t)gray_size);
  std::memcpy(gray_bytes.ptrw(), gray, gray_size);
  std::free(gray);

  return Image::create_from_data(
    (int)width, (int)height, false, Image::FORMAT_L8, gray_bytes
  );
}

} // namespace godot
