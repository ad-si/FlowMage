extends GraphEdit

const graph_nodes := [
  {
    "name": "Input/Image",
    "scene": preload("res://GraphNodes/Image.tscn"),
  },
  {
    "name": "Transform3D/Grayscale",
    "scene": preload("res://GraphNodes/Grayscale.tscn"),
  }
]
var last_popup_position = null  # Vertex
var last_popup_source_id = null  # Instance id
const imageNodeToPath := {}  # Mappings of `nodeName: path`


func _ready():
  for graph_node in graph_nodes:
    $NodeSelector.add_item(graph_node.name)
  await get_tree().process_frame
  _center_on_show()


func _center_on_show():
  var show_node := $Show
  scroll_offset = (show_node.position_offset - size / 2 + show_node.size / 2)


func _evaluate_node(node_name: StringName, connections: Array) -> Image:
  var input_image: Image = null
  for conn in connections:
    if conn.to_node == node_name:
      input_image = _evaluate_node(conn.from_node, connections)
      break
  var node := get_node_or_null(NodePath(String(node_name)))
  if node == null or not node.has_method("evaluate"):
    return input_image
  return node.evaluate(input_image)


func trigger_image_synthesis():
  var connection_list := get_connection_list()
  var result: Image = null
  for conn in connection_list:
    if conn.to_node == &"Show":
      result = _evaluate_node(conn.from_node, connection_list)
      break

  var texture_rect := $"../../TextureRect"
  if texture_rect:
    texture_rect.render_image(result)


func _on_GraphEdit_popup_request(pos):
  $NodeSelector.set_position(pos)
  $NodeSelector.popup()

  last_popup_position = pos - get_screen_position()


func _on_PopupMenu_id_pressed(id: int):
  var selected_node = graph_nodes[id]
  var node_instance = selected_node.scene.instantiate()
  add_child(node_instance)

  if last_popup_position != null:
    node_instance.position_offset = (last_popup_position + scroll_offset) / zoom


func _on_file_dialog_request(source_node_id):
  print("Open File Dialog")
  $"../../FileDialog".popup()
  last_popup_source_id = source_node_id


func _on_FileDialog_file_selected(path):
  var graph_node_instance = instance_from_id(last_popup_source_id)
  graph_node_instance.set_loaded_path(path)
  #imageNodeToPath[graph_node_instance.name] = path
  last_popup_source_id = null


func _on_GraphEdit_connection_request(from: String, from_slot: int, to: String, to_slot: int):
  # Ensure there is only 1 connection to `Show`
  if to == "Show":
    for connection in get_connection_list():
      if connection.to_node == &"Show":
        disconnect_node(
          connection.from_node, connection.from_port, connection.to_node, connection.to_port
        )
  self.connect_node(from, from_slot, to, to_slot)

  trigger_image_synthesis()


func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
  disconnect_node(from, from_slot, to, to_slot)
  trigger_image_synthesis()


func _on_GraphEdit_delete_nodes_request():
#	TODO: Delete node from imageNodeToPath
  pass  # Replace with function body.
