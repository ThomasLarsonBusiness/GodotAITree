@tool
extends GraphNode
class_name RandomGraphNode

# Fields
var inputUsed : bool = false
var associatedNodes : Array[GraphNode] = []
var associatedPorts : Array[int] = []
var providedData = {}

# Ready function
func _ready():
	# if data is provided, load in the data
	if providedData != {}:
		load_data()

# Adds a New Weight/Connection Point
func _on_add_node_button_pressed():
	# Add the New HBox
	var container = HBoxContainer.new()
	container.custom_minimum_size = Vector2(0, 30)
	get_children()[associatedNodes.size()].add_sibling(container)
	
	# Add the Weight Text Edit
	var weightEdit = TextEdit.new()
	weightEdit.custom_minimum_size = Vector2(120, 30)
	weightEdit.placeholder_text = "Weight as Float"
	weightEdit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(weightEdit)
	
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
	deleteBtn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	deleteBtn.size_flags_stretch_ratio = 0.5
	deleteBtn.pressed.connect(_on_delete_button_pressed.bind(container))
	container.add_child(deleteBtn)
	
	# Append New Null to Associated Nodes
	associatedNodes.append(null)
	associatedPorts.append(-1)
	
	# Enable the Slot
	set_slot_enabled_right(associatedNodes.size(), true)

# Removes the Child and Adjusts the Remaining Labels and connections
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
	
	# Adjust Labels and Connections
	children = get_children()
	
	# Loops through the lower connections and adjusts them as needed
	for index in range(removalIndex, associatedNodes.size()):
		if children[index] is Button:
			continue
		
		# Fix Label
		children[index + 1].get_child(1).text = "Node " + str(index)
		
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

# Updates whether there is an input connection
func update_input(value : bool):
	inputUsed = value

# Checks if there is an input connection
func check_input() -> bool:
	return !inputUsed

# Adds a new connection 
func add_output(graph : GraphEdit, node : Node, from_port : int, to_port : int):
	# If the output is already in use, then remove the current connection
	if associatedNodes[from_port] != null:
		graph.disconnect_node(name, from_port, associatedNodes[from_port].name, associatedPorts[from_port])
		associatedNodes[from_port].tree_exiting.disconnect(_delete_connection)
		associatedNodes[from_port].update_input(false)
	
	# Connect the new node to this node
	associatedNodes[from_port] = node
	node.tree_exiting.connect(_delete_connection.bind(graph, from_port, node, to_port))
	associatedPorts[from_port] = to_port

# Removes the connection data for a specific output port
func remove_connection(from_port : int):
	associatedNodes[from_port].tree_exiting.disconnect(_delete_connection)
	associatedNodes[from_port] = null
	associatedPorts[from_port] = -1

# When this node is deleted. Cleans up the Input slots of the associated nodes
func delete_node(graph : GraphEdit):
	for i in associatedNodes.size():
		if associatedNodes[i] != null:
			graph.disconnect_node(name, i, associatedNodes[i].name, associatedPorts[i])
			associatedNodes[i].update_input(false)

# Handles when a connection is deleted
func _delete_connection(graph : GraphEdit, fromPort : int, toNode : Node, toPort : int):
	graph.disconnect_node(name, fromPort, toNode.name, toPort)
	remove_connection(fromPort - 1)

# Loads in and assigns the provided data
func load_data():
	$TitleContainer/ExclusiveCheckbox.button_pressed = providedData["Exclusive"]
	var nodes = providedData["Nodes"]
	for i in nodes.size():
		_on_add_node_button_pressed()
		get_children()[i + 1].get_child(0).text = str(providedData["Nodes"][i]["Weight"])

# Saves the data to the resource
func save():
	# Creates the child nodes
	var nodeData = []
	var children = get_children()
	
	for index in associatedNodes.size():
		# Gets the Weight for the Label
		var data
		if !get_children()[index + 1].get_child(0).text.is_valid_float(): 
			print("Weight " + str(index) + " Not a Valid Float")
			data = {"Weight": 0}
		else:
			data = {"Weight": float(children[index + 1].get_child(0).text)}
		
		# If the associated node exists, save the node
		if associatedNodes[index] != null:
			data["Node"] = associatedNodes[index].save()
		else:
			data["Node"] = null
		
		nodeData.append(data)
	
	# Returns the data with the connected nodes
	return {
		"Type": "Random Node",
		"Position": {
			"X": position_offset.x as int,
			"Y": position_offset.y as int,
		},
		"Nodes": nodeData,
		"Exclusive": get_node("TitleContainer/ExclusiveCheckbox").button_pressed
	}
