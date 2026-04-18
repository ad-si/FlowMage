extends GraphEdit

const graph_nodes := [
  {
    "name": "Input/Image",
    "scene": preload ("res://GraphNodes/Image.tscn"),
  },
  {
    "name": "Transform3D/Grayscale",
    "scene": preload ("res://GraphNodes/Grayscale.tscn"),
  }
]
var last_popup_position = null # Vertex
var last_popup_source_id = null # Instance id
const imageNodeToPath := {} # Mappings of `nodeName: path`


func _ready():
  for graph_node in graph_nodes:
    $NodeSelector.add_item(graph_node.name)
  await get_tree().process_frame
  _center_on_show()

func _center_on_show():
  var show_node := $Show
  scroll_offset = (
    show_node.position_offset
    - size / 2
    + show_node.size / 2
  )

# Sorted with increasing distance to node
func find_upstream_connections(connection_list, node):
  var upstream_connections := []
  for connection in connection_list:
    if connection.to_node == node:
      upstream_connections.append_array(
        find_upstream_connections(connection_list, connection.from_node)
      )
      upstream_connections.append(connection)
  return upstream_connections

func trigger_image_synthesis():
  var connection_list := get_connection_list()
  var relevant_connections = find_upstream_connections(
      connection_list,
      &"Show"
    )

  var texture_rect := $"../../TextureRect"
  var image_path := ""

  for conn in relevant_connections:
    if String(conn.from_node).matchn("*ImageSelectNode*"):
      var image_node := get_node_or_null(NodePath(String(conn.from_node)))
      if image_node and image_node.current_path != "":
        image_path = image_node.current_path

  if texture_rect:
    if image_path != "":
      texture_rect.render_image(image_path)
    else:
      texture_rect.clear()

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

func _on_GraphEdit_connection_request(
    from: String, from_slot: int,
    to: String, to_slot: int
  ):

  # Ensure there is only 1 connection to `Show`
  if to == "Show":
    for connection in get_connection_list():
      if connection.to_node == &"Show":
        disconnect_node(
          connection.from_node, connection.from_port,
          connection.to_node, connection.to_port
        )

  self.connect_node(from, from_slot, to, to_slot)

  trigger_image_synthesis()

func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
  disconnect_node(from, from_slot, to, to_slot)
  trigger_image_synthesis()

func _on_GraphEdit_delete_nodes_request():
#	TODO: Delete node from imageNodeToPath
  pass # Replace with function body.
