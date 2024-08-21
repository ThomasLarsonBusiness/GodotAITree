@tool
extends Control

# Node Data
const CondNode = preload("res://addons/AITree/GraphNodes/ConditionalGraphNode.tscn")
const RandNode = preload("res://addons/AITree/GraphNodes/RandomGraphNode.tscn")
const SeqNode = preload("res://addons/AITree/GraphNodes/SequenceGraphNode.tscn")
const ActNode = preload("res://addons/AITree/GraphNodes/ActionGraphNode.tscn")
const SelNode = preload("res://addons/AITree/GraphNodes/SelectorGraphNode.tscn")
const ProcNode = preload("res://addons/AITree/GraphNodes/ProcessGraphNode.tscn")
const DelNode = preload("res://addons/AITree/GraphNodes/DelayGraphNode.tscn")
var linkedResource : TreeData

# Graph Variables
var graphEdit : GraphEdit
var rootNode : GraphNode
var selectedNodes = {}
var currentScene

# On Ready, defines and gets all necessary elements
func _ready():
	set_deferred("currentScene", get_tree().edited_scene_root)
	get_tree().tree_changed.connect(_on_tree_changed)
	
	graphEdit = get_node("HSplitContainer/GraphEdit")
	rootNode = get_node("HSplitContainer/GraphEdit/RootNode")

# When the User Changes The Edited Scene, Reload the Tree on the Graph
func _on_tree_changed():
	if is_inside_tree() and currentScene != get_tree().edited_scene_root:
		# Resets data information
		linkedResource == null
		if selectedNodes != { } and selectedNodes != null:
			selectedNodes.clear()
		
		# If an AITree Node is Present, Load the Tree Data
		currentScene = get_tree().edited_scene_root
		if currentScene.get_node_or_null("AITree") != null:
			$HSplitContainer/NotFound.hide()
			graphEdit.show()
			linkedResource = currentScene.get_node("AITree").treeData
			if linkedResource != null:
				load_data(linkedResource)
		# Else show the Error Screen
		else:
			$HSplitContainer/NotFound.show()
			graphEdit.hide()

# Creates a new Action Node
func _on_action_button_pressed():
	graphEdit.add_child(ActNode.instantiate())

# Creates a new Conditional Node
func _on_conditional_button_presed():
	graphEdit.add_child(CondNode.instantiate())

# Creates a new Random Node
func _on_random_button_pressed():
	graphEdit.add_child(RandNode.instantiate())

# Creates a new Sequence Node
func _on_sequence_button_pressed():
	graphEdit.add_child(SeqNode.instantiate())

# Creates a new Selector Node
func _on_selector_button_pressed():
	graphEdit.add_child(SelNode.instantiate())

# Creates a New Process Node
func _on_process_button_pressed():
	graphEdit.add_child(ProcNode.instantiate())

# Creates a new Delay Node
func _on_delay_button_pressed():
	graphEdit.add_child(DelNode.instantiate())

# Saves the Tree Information to the linked Resource
func _on_save_button_pressed():
	linkedResource.data = rootNode.save()

# Loads in Data From An Existing Resource
func load_data(res : Resource):	
	# Clear Previous Data
	graphEdit.clear_connections()
	for node in graphEdit.get_children():
		if node.name != "RootNode":
			node.queue_free()
	
	# Implement New Data
	if res.data != {}:
		rootNode.position_offset = Vector2(res.data["Position"]["X"], res.data["Position"]["Y"])
		if linkedResource.data["Root"]:
			var root = await build_node(linkedResource.data["Root"])
			graphEdit.connection_request.emit(rootNode.name, 0, root.name, 0)

# Builds a Node, Recursing Through the Data as Necessary
func build_node(data):
	# Creates an Action Node. Base Case
	if data["Type"] == "Action Node":
		var node = ActNode.instantiate()
		node.position_offset = Vector2(data["Position"]["X"], data["Position"]["Y"])
		node.providedData = data
		graphEdit.add_child(node)
		return node
	
	# Creates a Conditional Node. Builds True and False Nodes
	if data["Type"] == "Conditional Node":
		var node = CondNode.instantiate()
		node.position_offset = Vector2(data["Position"]["X"], data["Position"]["Y"])
		node.providedData = data
		graphEdit.add_child(node)
		
		if data["TrueNode"] != null:
			var trueNode = await build_node(data["TrueNode"])
			graphEdit.connection_request.emit(node.name, 0, trueNode.name, 0)
		if data["FalseNode"] != null:
			var falseNode = await build_node(data["FalseNode"])
			graphEdit.connection_request.emit(node.name, 1, falseNode.name, 0)
		
		return node
	
	# Creates a Random Node. Builds List of Random Nodes
	if data["Type"] == "Random Node":
		var node = RandNode.instantiate()
		node.position_offset = Vector2(data["Position"]["X"], data["Position"]["Y"])
		node.providedData = data
		graphEdit.add_child(node)
		
		for i in data["Nodes"].size():
			if data["Nodes"][i]["Node"] != null:
				var connectedNode = await build_node(data["Nodes"][i]["Node"])
				graphEdit.connection_request.emit(node.name, i, connectedNode.name, 0)
		
		return node
	
	if data["Type"] == "Sequence Node":
		var node = SeqNode.instantiate()
		node.position_offset = Vector2(data["Position"]["X"], data["Position"]["Y"])
		node.providedData = data
		graphEdit.add_child(node)
		
		for i in data["Nodes"].size():
			if data["Nodes"][i] != null:
				var connectedNode = await build_node(data["Nodes"][i])
				graphEdit.connection_request.emit(node.name, i, connectedNode.name, 0)
		
		return node
	
	if data["Type"] == "Selector Node":
		var node = SelNode.instantiate()
		node.position_offset = Vector2(data["Position"]["X"], data["Position"]["Y"])
		node.providedData = data
		graphEdit.add_child(node)
		
		for i in data["Nodes"].size():
			if data["Nodes"][i] != null:
				var connectedNode = await build_node(data["Nodes"][i])
				graphEdit.connection_request.emit(node.name, i, connectedNode.name, 0)
		
		return node
	
	if data["Type"] == "Process Node":
		var node = ProcNode.instantiate()
		node.position_offset = Vector2(data["Position"]["X"], data["Position"]["Y"])
		node.providedData = data
		graphEdit.add_child(node)
		
		for i in data["Nodes"].size():
			if data["Nodes"][i] != null:
				var connectedNode = await build_node(data["Nodes"][i])
				graphEdit.connection_request.emit(node.name, i, connectedNode.name, 0)
		
		return node
	
	if data["Type"] == "Delay Node":
		var node = DelNode.instantiate()
		node.position_offset = Vector2(data["Position"]["X"], data["Position"]["Y"])
		node.providedData = data
		graphEdit.add_child(node)
		
		return node

# Add a Selected Node to the Array
func _on_graph_edit_node_selected(node):
	selectedNodes[node] = true

# Remove a Selected Node from the Array
func _on_graph_edit_node_deselected(node):
	selectedNodes[node] = false

# Deletes all selected nodes
func _on_graph_edit_delete_nodes_request(nodes):
	for node in selectedNodes.keys():
		if selectedNodes[node] and node != rootNode:
			# Run Delete Function
			node.delete_node(graphEdit)
			
			# Delete Node
			node.queue_free()
	
	selectedNodes = {}

# Connects two nodes together
func _on_graph_edit_connection_request(from_node, from_port, to_node, to_port):
	# Gets To and From Nodes
	var toNode = get_node("HSplitContainer/GraphEdit/" + to_node)
	var fromNode = get_node("HSplitContainer/GraphEdit/" + from_node)
	
	# Checks the To Node's Input
	var success = toNode.check_input()
	
	if success:
		get_node("HSplitContainer/GraphEdit").connect_node(from_node, from_port, to_node, to_port)
		toNode.update_input(true)
		fromNode.add_output(get_node("HSplitContainer/GraphEdit"), toNode, from_port, to_port)

# Disconnects two linked nodes
func _on_graph_edit_disconnection_request(from_node, from_port, to_node, to_port):
	# Gets To and From Nodes
	var toNode = get_node("HSplitContainer/GraphEdit/" + to_node)
	var fromNode = get_node("HSplitContainer/GraphEdit/" + from_node)
	
	graphEdit.disconnect_node(from_node, from_port, to_node, to_port)
	
	toNode.update_input(false)
	fromNode.remove_connection(from_port)



