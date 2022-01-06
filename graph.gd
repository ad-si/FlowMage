extends GraphEdit

var graph_nodes := [
	{
		"name": "Input/Image",
		"scene": preload("res://GraphNodes/Image.tscn"),
	},
	{
		"name": "Transform/Grayscale",
		"scene": preload("res://GraphNodes/Grayscale.tscn"),
	}
]
var last_popup_position = null  # Vertex
var last_popup_source_id = null  # Instance id


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

	print(relevant_connections)


func _on_GraphEdit_popup_request(position):
	position.x -= self.get_position().x
	position.y -= self.get_position().y
	
	$NodeSelector.set_position(position)
	$NodeSelector.popup()
	
	last_popup_position = position


func _on_PopupMenu_id_pressed(id: int):
	var selected_node = graph_nodes[id]
	# prints('Selected:', selected_node.name)

	var node_instance = selected_node.scene.instance()

	if selected_node.name == "Input/Image":
		node_instance.connect(
			"file_dialog_request", 
			self, 
			"_on_file_dialog_request"
		)

	if last_popup_position != null:
		node_instance.set_offset(last_popup_position)

	add_child(node_instance)


func _on_file_dialog_request(source_node_id):
	$"../../FileDialog".popup()
	last_popup_source_id = source_node_id


func _on_FileDialog_file_selected(path):
	var graph_node_instance = instance_from_id(last_popup_source_id)
	graph_node_instance.set_loaded_path(path)
	last_popup_source_id = null


func _on_GraphEdit_connection_request(
		from: String, from_slot: int,
		to: String, to_slot: int 
	):

	# Ensure there is only 1 connection to `Show`
	if to == "Show":
		for connection in get_connection_list():
			if connection.to == "Show":
				return

	self.connect_node(from, from_slot, to, to_slot)
	
	trigger_image_synthesis()


func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	disconnect_node(from, from_slot, to, to_slot)
