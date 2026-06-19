#pragma once

#include <godot_cpp/classes/image.hpp>
#include <godot_cpp/classes/object.hpp>

namespace godot {

class FlatCV : public Object {
  GDCLASS(FlatCV, Object);

protected:
  static void _bind_methods();

public:
  // Color / tone
  static Ref<Image> rgba_to_grayscale(const Ref<Image> &p_image);
  static Ref<Image> grayscale(const Ref<Image> &p_image);
  static Ref<Image> grayscale_stretch(const Ref<Image> &p_image);

  // Filters
  static Ref<Image> gaussian_blur(const Ref<Image> &p_image, double p_radius);
  static Ref<Image> sobel_edge_detection(const Ref<Image> &p_image);

  // Threshold / binarize
  static Ref<Image> otsu_threshold(const Ref<Image> &p_image, bool p_double_threshold);
  static Ref<Image> bw_smart(const Ref<Image> &p_image, bool p_double_threshold);
  static Ref<Image> convert_to_binary(
    const Ref<Image> &p_image,
    const String &p_foreground_hex,
    const String &p_background_hex
  );

  // Binary morphology (disk structuring element)
  static Ref<Image> binary_dilation(const Ref<Image> &p_image, int p_radius);
  static Ref<Image> binary_erosion(const Ref<Image> &p_image, int p_radius);
  static Ref<Image> binary_opening(const Ref<Image> &p_image, int p_radius);
  static Ref<Image> binary_closing(const Ref<Image> &p_image, int p_radius);

  // Geometry
  static Ref<Image> flip_x(const Ref<Image> &p_image);
  static Ref<Image> flip_y(const Ref<Image> &p_image);
  static Ref<Image> transpose(const Ref<Image> &p_image);
  static Ref<Image> transverse(const Ref<Image> &p_image);
  static Ref<Image> rotate_90_cw(const Ref<Image> &p_image);
  static Ref<Image> rotate_180(const Ref<Image> &p_image);
  static Ref<Image> rotate_270_cw(const Ref<Image> &p_image);
  static Ref<Image> resize(const Ref<Image> &p_image, double p_scale_x, double p_scale_y);
  static Ref<Image> crop(
    const Ref<Image> &p_image,
    int p_x,
    int p_y,
    int p_width,
    int p_height
  );
  static Ref<Image> trim(const Ref<Image> &p_image);
  static Ref<Image> trim_threshold(const Ref<Image> &p_image, double p_threshold_percent);

  // Channels
  static Ref<Image> single_to_multichannel(const Ref<Image> &p_image);

  // Document
  static Ref<Image> extract_document(const Ref<Image> &p_image);

  // Analysis
  static Ref<Image> histogram(const Ref<Image> &p_image);
};

} // namespace godot
