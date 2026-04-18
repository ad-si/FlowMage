class_name FlowNode
extends GraphNode

const FlowSpinner := preload("res://GraphNodes/spinner.gd")

const NODE_BG_COLOR := Color(0.27, 0.27, 0.27)
const NODE_CORNER_RADIUS := 4
const NODE_SELECTED_BORDER_WIDTH := 2

signal replace_requested(node)

var pass_through: bool = false
var _spinner: Control = null


func _ready() -> void:
  _build_titlebar_buttons()


static func style_graph_node(node: GraphNode, header_color: Color) -> void:
  var panel := StyleBoxFlat.new()
  panel.bg_color = NODE_BG_COLOR
  panel.corner_radius_bottom_left = NODE_CORNER_RADIUS
  panel.corner_radius_bottom_right = NODE_CORNER_RADIUS
  panel.content_margin_left = 4
  panel.content_margin_right = 4
  panel.content_margin_top = 4
  panel.content_margin_bottom = 4
  node.add_theme_stylebox_override("panel", panel)

  var panel_selected: StyleBoxFlat = panel.duplicate()
  panel_selected.border_color = header_color
  panel_selected.border_width_left = NODE_SELECTED_BORDER_WIDTH
  panel_selected.border_width_right = NODE_SELECTED_BORDER_WIDTH
  panel_selected.border_width_bottom = NODE_SELECTED_BORDER_WIDTH
  node.add_theme_stylebox_override("panel_selected", panel_selected)

  var titlebar := StyleBoxFlat.new()
  titlebar.bg_color = header_color
  titlebar.corner_radius_top_left = NODE_CORNER_RADIUS
  titlebar.corner_radius_top_right = NODE_CORNER_RADIUS
  titlebar.content_margin_left = 8
  titlebar.content_margin_right = 4
  titlebar.content_margin_top = 4
  titlebar.content_margin_bottom = 4
  node.add_theme_stylebox_override("titlebar", titlebar)

  var titlebar_selected: StyleBoxFlat = titlebar.duplicate()
  titlebar_selected.border_color = header_color
  titlebar_selected.border_width_left = NODE_SELECTED_BORDER_WIDTH
  titlebar_selected.border_width_right = NODE_SELECTED_BORDER_WIDTH
  titlebar_selected.border_width_top = NODE_SELECTED_BORDER_WIDTH
  node.add_theme_stylebox_override("titlebar_selected", titlebar_selected)


func _build_titlebar_buttons() -> void:
  var titlebar := get_titlebar_hbox()

  _spinner = FlowSpinner.new()
  _spinner.custom_minimum_size = Vector2(22, 22)
  titlebar.add_child(_spinner)

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
  if graph and graph.has_method("_perform_delete_nodes"):
    graph.call_deferred("_perform_delete_nodes", [name])


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


func show_spinner() -> void:
  if _spinner:
    _spinner.set_spinning(true)


func hide_spinner() -> void:
  if _spinner:
    _spinner.set_spinning(false)


func evaluate(input):
  if pass_through:
    return input
  return _evaluate_internal(input)


# _evaluate_internal runs on a WorkerThreadPool thread.
# Overrides must be thread-safe: no scene-tree mutation, no UI access,
# and only read node state that isn't mutated from the main thread mid-eval.
func evaluate_async(input):
  if pass_through:
    return input
  var holder := {"result": null}
  var task_id: int = WorkerThreadPool.add_task(
    func(): holder.result = _evaluate_internal(input)
  )
  while not WorkerThreadPool.is_task_completed(task_id):
    await get_tree().process_frame
  WorkerThreadPool.wait_for_task_completion(task_id)
  return holder.result


func _evaluate_internal(input):
  return input


func get_documentation() -> String:
  return "No documentation available for this node."
