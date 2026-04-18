extends Panel

func _ready():
  var window := get_window()
  var scale := DisplayServer.screen_get_scale()
  var initial_center := window.position + window.size / 2
  window.content_scale_factor = scale
  window.size = Vector2i(int(1280 * scale), int(800 * scale))
  window.position = initial_center - window.size / 2
