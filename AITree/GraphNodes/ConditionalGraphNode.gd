@tool
extends GraphNode
class_name ConditionalGraphNode

# Fields
@onready var booleanOptions = get_node("BottomRow/BooleanOptions")

var inputUsed : bool = false
var arrayOfBools : Array[String] = []
var associatedNodes = [null, null]
var associatedPorts = [-1, -1]
var providedData = {}

# Generates the List of Available Booleans and Loads in the Data if present
func _ready():
	# Clears items to prevent cached items
	booleanOptions.clear()
	
	# If the node is properly loaded
	if is_inside_tree():
		# Gets a List of Booleans and Creates Dropdown Items
		var varList = get_tree().edited_scene_root.get_script().get_script_property_list()
		var booleans = []
		for element in varList:
			if element["type"] == 1:
				var boolName = element["name"]
				booleanOptions.add_item(boolName)
				arrayOfBools.append(boolName)
	
	# If Data has Been provided, load in the data
	if providedData != {}:
		load_data()

# Checks if an input is attached to this node
func check_input():
	return !inputUsed

# Updates if there is an input attached to this node
func update_input(value):
	inputUsed = value

# Adds a new node to an output Port
func add_output(graph : GraphEdit, node : Node, from_port : int, to_port : int):
	# Removes the currently associated node from selected output port
	if associatedNodes[from_port] != null:
		graph.disconnect_node(name, from_port, associatedNodes[from_port].name, associatedPorts[from_port])
		associatedNodes[from_port].tree_exiting.disconnect(_delete_connection)
		associatedNodes[from_port].update_input(false)
	
	# Attaches the provided node to the output port
	associatedNodes[from_port] = node
	node.tree_exiting.connect(_delete_connection.bind(graph, from_port, node, to_port))
	associatedPorts[from_port] = to_port

# Removes a connection from stored port information
func remove_connection(from_port : int):
	associatedNodes[from_port] = null
	associatedPorts[from_port] = -1

# When this node is deleted, update associated nodes input status and disconnect them from this node
func delete_node(graph : GraphEdit):
	for i in 2:
		if associatedNodes[i] != null:
			associatedNodes[i].update_input(false)
			graph.disconnect_node(name, i, associatedNodes[i].name, associatedPorts[i])

# When a node is disconnected, remove the connection and the related data
func _delete_connection(graph : GraphEdit, fromPort : int, toNode : Node, toPort : int):
	graph.disconnect_node(name, fromPort, toNode.name, toPort)
	remove_connection(fromPort)

# Loads in the data to the correct places
func load_data():
	# Sets the Correct Boolean
	for index in booleanOptions.item_count:
		if booleanOptions.get_item_text(index) == providedData["BoolName"]:
			booleanOptions.select(index)

# Saves the data to the resource
func save():
	var trueData = null
	var falseData = null
	
	if associatedNodes[0] != null:
		trueData = associatedNodes[0].save()
	if associatedNodes[1] != null:
		falseData = associatedNodes[1].save()
	
	return {
		"Type": "Conditional Node",
		"Position": {
			"X": position_offset.x as int,
			"Y": position_offset.y as int
		},
		"BoolName": booleanOptions.get_item_text(booleanOptions.selected),
		"TrueNode" : trueData,
		"FalseNode" : falseData
	}
