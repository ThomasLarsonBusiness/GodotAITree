@tool
extends GraphNode
class_name RootNode

# Fields
var rootNode = null
var rootPort = -1

# Adds a node as an output, removing the previous output node if it exists
func add_output(graph : GraphEdit, node : Node, from_port : int, to_port : int):
	# Removes previous output node, if connected
	if rootNode != null:
		graph.disconnect_node(name, 0, rootNode.name, rootPort)
		rootNode.tree_exiting.disconnect(_delete_connection)
		rootNode.update_input(false)
	
	# Sets up the New Output Node
	rootNode = node
	rootNode.tree_exiting.connect(_delete_connection.bind(graph, to_port))
	rootPort = to_port

# Removes connection info
func remove_connection(from_port : int):
	rootNode = null
	rootPort = -1

# Deletes a connection and cleans up related variables
func _delete_connection(graph : GraphEdit, toPort : int):
	graph.disconnect_node(name, 0, rootNode.name, toPort)
	remove_connection(0)

# Saves the Root Node Data
func save():
	# Creates the Root Node Data
	var rootData = null
	if rootNode:
		rootData = rootNode.save()
	
	# Returns the Data to Be Saved
	return {
		"Position": {
			"X" : position_offset.x as int,
			"Y" : position_offset.y as int
		},
		"Root": rootData
	}
