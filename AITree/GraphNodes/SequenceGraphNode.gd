@tool
extends GraphNode
class_name SequenceGraphNode

# Fields
var inputUsed : bool = false
var associatedNodes : Array[GraphNode] = []
var associatedPorts : Array[int] = []
var providedData = {}

# Ready Function
func _ready():
	# If data is provided, load in the data
	if providedData != {}:
		load_data()

# Adds a New Weight/Connection Point
func _on_add_node_button_pressed():
	# Add the New HBox
	var container = HBoxContainer.new()
	container.custom_minimum_size = Vector2(0, 30)
	get_children()[associatedNodes.size()].add_sibling(container)
	
	# Add the Node Label
	var nodeLabel = Label.new()
	nodeLabel.custom_minimum_size = Vector2(120, 30)
	nodeLabel.text = "Node " + str(associatedNodes.size() + 1)
	nodeLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	nodeLabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(nodeLabel)
	
	# Add Delete Button
	var deleteBtn = Button.new()
	deleteBtn.custom_minimum_size = Vector2(30, 30)
	deleteBtn.text = "-"
	deleteBtn.size_flags_vertical = Control.SIZE_SHRINK_END
	deleteBtn.size_flags_stretch_ratio = 0.5
	deleteBtn.pressed.connect(_on_delete_button_pressed.bind(container))
	container.add_child(deleteBtn)
	
	# Append New Null to Associated Nodes
	associatedNodes.append(null)
	associatedPorts.append(-1)
	
	# Enable the Slot
	set_slot_enabled_right(associatedNodes.size(), true)

# When a delete Button is pressed next to a node, remove it and adjust connections
func _on_delete_button_pressed(node):
	# Remove the Correct Child
	var children = get_children()
	var removalIndex : int
	var associatedIndex : int
	for index in range(1, children.size()):
		if children[index] == node:
			removalIndex = index
			associatedIndex = index - 1
			break
	
	# Clear Linked Data
	if associatedNodes[associatedIndex] != null:
		get_node("../").disconnect_node(name, associatedIndex, associatedNodes[associatedIndex].name, associatedPorts[associatedIndex])
		associatedNodes[associatedIndex].tree_exiting.disconnect(_delete_connection)
		associatedNodes[associatedIndex].update_input(false)
	
	
	# For each child, adjust the labels and the connections
	children = get_children()
	for index in range(removalIndex, associatedNodes.size()):
		if children[index] is Button:
			continue
		
		# Fix Label
		children[index + 1].get_child(0).text = "Node " + str(index)
		
		# Disconnect and Reconnect Associated Node
		if associatedNodes[index] != null:
			get_parent().disconnect_node(name, index, associatedNodes[index].name, 0)
			get_parent().connect_node(name, index - 1, associatedNodes[index].name, 0)
	
	# Removes Necessary Contents
	remove_child(node)
	node.queue_free()
	set_slot_enabled_right(associatedNodes.size(), false)
	associatedNodes.remove_at(associatedIndex)
	associatedPorts.remove_at(associatedIndex)

# Updates whether this node has an input
func update_input(value : bool):
	inputUsed = value

# Checks if the node has an input
func check_input() -> bool:
	return !inputUsed

# Adds a node to one of the outputs
func add_output(graph : GraphEdit, node : Node, from_port : int, to_port : int):
	# Removes the currently connected node if necessary
	if associatedNodes[from_port] != null:
		graph.disconnect_node(name, from_port, associatedNodes[from_port].name, associatedPorts[from_port])
		associatedNodes[from_port].tree_exiting.disconnect(_delete_connection)
		associatedNodes[from_port].update_input(false)
	
	# Connects to the node to the correct port
	associatedNodes[from_port] = node
	node.tree_exiting.connect(_delete_connection.bind(graph, from_port, node, to_port))
	associatedPorts[from_port] = to_port

# Removes the necessary connection information from this node
func remove_connection(from_port : int):
	associatedNodes[from_port].tree_exiting.disconnect(_delete_connection)
	associatedNodes[from_port] = null
	associatedPorts[from_port] = -1

# When this node is deleted, cleanup the inputs on the associated nodes
func delete_node(graph : GraphEdit):
	for i in associatedNodes.size():
		if associatedNodes[i] != null:
			graph.disconnect_node(name, i, associatedNodes[i].name, associatedPorts[i])
			associatedNodes[i].update_input(false)

# Removes a connection from this node
func _delete_connection(graph : GraphEdit, fromPort : int, toNode : Node, toPort : int):
	graph.disconnect_node(name, fromPort, toNode.name, toPort)
	remove_connection(fromPort - 1)

# Loads in and assigns the provided data
func load_data():
	$InputData/ResetCheck.button_pressed = providedData["Reset"]
	
	var nodes = providedData["Nodes"]
	for i in nodes.size():
		_on_add_node_button_pressed()

# Saves the data to the resource
func save():
	var nodeData = []
	var children = get_children()
	
	for node in associatedNodes:
		if node != null:
			nodeData.append(node.save())
		else:
			nodeData.append(null)
	
	return {
		"Type": "Sequence Node",
		"Position": {
			"X": position_offset.x as int,
			"Y": position_offset.y as int,
		},
		"Reset": $InputData/ResetCheck.button_pressed,
		"Nodes": nodeData
	}
