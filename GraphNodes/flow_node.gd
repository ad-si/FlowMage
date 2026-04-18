class_name FlowNode
extends GraphNode

signal replace_requested(node)

var pass_through: bool = false


func _ready() -> void:
  _build_titlebar_buttons()


func _build_titlebar_buttons() -> void:
  var titlebar := get_titlebar_hbox()

  if get_input_port_count() > 0:
    var pass_btn := _make_icon_button("⇥", "Toggle pass-through mode", true)
    pass_btn.toggled.connect(_on_pass_toggled)
    titlebar.add_child(pass_btn)

  var replace_btn := _make_icon_button("↻", "Replace with another node type", false)
  replace_btn.pressed.connect(_on_replace_pressed)
  titlebar.add_child(replace_btn)

  var docs_btn := _make_icon_button("?", "Show documentation", false)
  docs_btn.pressed.connect(_on_docs_pressed)
  titlebar.add_child(docs_btn)

  var delete_btn := _make_icon_button("✕", "Delete this node", false)
  delete_btn.pressed.connect(_on_delete_pressed)
  titlebar.add_child(delete_btn)


func _make_icon_button(glyph: String, tooltip: String, toggle: bool) -> Button:
  var btn := Button.new()
  btn.text = glyph
  btn.toggle_mode = toggle
  btn.flat = true
  btn.focus_mode = Control.FOCUS_NONE
  btn.tooltip_text = tooltip
  btn.custom_minimum_size = Vector2(22, 22)
  btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
  return btn


func _on_pass_toggled(pressed: bool) -> void:
  pass_through = pressed
  _update_pass_through_visual()
  var graph := get_parent()
  if graph and graph.has_method("trigger_image_synthesis"):
    graph.trigger_image_synthesis()


func _update_pass_through_visual() -> void:
  if pass_through:
    self_modulate = Color(0.55, 0.55, 0.55, 1.0)
  else:
    self_modulate = Color.WHITE


func _on_replace_pressed() -> void:
  replace_requested.emit(self)


func _on_delete_pressed() -> void:
  var graph := get_parent()
  queue_free()
  if graph and graph.has_method("trigger_image_synthesis"):
    graph.call_deferred("trigger_image_synthesis")


func _on_docs_pressed() -> void:
  var dialog := AcceptDialog.new()
  dialog.title = "%s — Documentation" % title
  dialog.dialog_text = get_documentation()
  dialog.min_size = Vector2(420, 200)
  dialog.exclusive = false
  get_tree().current_scene.add_child(dialog)
  dialog.confirmed.connect(dialog.queue_free)
  dialog.close_requested.connect(dialog.queue_free)
  dialog.popup_centered()


func evaluate(input):
  if pass_through:
    return input
  return _evaluate_internal(input)


func _evaluate_internal(input):
  return input


func get_documentation() -> String:
  return "No documentation available for this node."
