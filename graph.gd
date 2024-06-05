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

# Sorted with increasing distance to node
func find_upstream_connections(connection_list, node):
	var upstream_connections := []
	for connection in connection_list:
		if connection.to == node:
			upstream_connections.append_array(
				find_upstream_connections(connection_list, connection.from)
			)
			upstream_connections.append(connection)
	return upstream_connections

func trigger_image_synthesis():
	var connection_list := get_connection_list()
	var relevant_connections = find_upstream_connections(
			connection_list,
			"Show"
		)

	for conn in relevant_connections:
		if conn.from.matchn("*ImageSelectNode*"):
			conn.magickCmd = imageNodeToPath.get(conn.from, "")
			printt(conn.from, conn.magickCmd)

	# print(relevant_connections)
	# [{from:ImageSelectNode, from_port:0, to:Show, to_port:0}]
	# [{from:@ImageSelectNode@110, from_port:0, to:Show, to_port:0}]

	# var output = []
	# OS.execute( 'magick', ['-version'], true, output )
	# for line in output:
	# 	print( line )

func _on_GraphEdit_popup_request(pos):
	pos.x -= self.get_position().x
	pos.y -= self.get_position().y

	$NodeSelector.set_position(pos)
	$NodeSelector.popup()

	last_popup_position = pos

func _on_PopupMenu_id_pressed(id: int):
	var selected_node = graph_nodes[id]
	var node_instance = selected_node.scene.instantiate()

	if last_popup_position != null:
		node_instance.set_position(last_popup_position)

	add_child(node_instance)

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
			if connection.to == "Show":
				disconnect_node(
					connection.from, connection.from_port,
					connection.to, connection.to_port
				)

	self.connect_node(from, from_slot, to, to_slot)

	trigger_image_synthesis()

func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	disconnect_node(from, from_slot, to, to_slot)

func _on_GraphEdit_delete_nodes_request():
#	TODO: Delete node from imageNodeToPath
	pass # Replace with function body.
