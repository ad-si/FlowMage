#pragma once

#include <godot_cpp/classes/image.hpp>
#include <godot_cpp/classes/object.hpp>

namespace godot {

class FlatCV : public Object {
  GDCLASS(FlatCV, Object);

protected:
  static void _bind_methods();

public:
  static Ref<Image> rgba_to_grayscale(const Ref<Image> &p_image);
};

} // namespace godot
