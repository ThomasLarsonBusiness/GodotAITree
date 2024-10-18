extends Node2D

# Fields
@export var treeData : TreeData
@onready var parent : Node = get_node("../")
var treeRoot : TreeNode
var branches : Dictionary
var branchDef = {}
var sequenceIDS = []

# When Ready, Builds the AI Tree
func _ready():
	treeRoot = await build_tree(treeData.data["Root"], "", "", true)
	add_sequence_blocking_nodes()

# Recurses through the Data, building TreeNodes as Needed
func build_tree(data, prevID : String, newChar : String, isRoot : bool = false):
	var node
	var currentID : String = prevID + newChar
	
	# Builds a Node, Based on its Type
	match data["Type"]:
		"Conditional Node":
			# Builds the Conditional Node
			node = ConditionalNode.new(data["BoolName"], parent)
			
			# Creates and Assigns the True and False Nodes
			if data["TrueNode"]: node.trueNode = await build_tree(data["TrueNode"], currentID, "A")
			if data["FalseNode"]: node.falseNode = await build_tree(data["FalseNode"], currentID, "B")
		
		"Action Node":
			# Builds the Action Node
			node = ActionNode.new()
			node.assign_callable(parent, data["CallableID"])
			node.variableList = define_variable_list(data["Variables"])
		
		"Random Node":
			# Creates the Random node and Adds all Linked Nodes
			node = RandomNode.new(data["Exclusive"])
			for index in data["Nodes"].size():
				node.add_node(await build_tree(data["Nodes"][index]["Node"], currentID, String.chr("A".unicode_at(0) + index)), float(data["Nodes"][index]["Weight"]))
		
		"Sequence Node":
			# Makes a Sequence Node and adds all the Valid Nodes to the Sequence
			node = SequenceNode.new(data["Reset"])
			for index in data["Nodes"].size():
				if data["Nodes"][index] != null:
					node.append_item_to_sequence(await build_tree(data["Nodes"][index], currentID, String.chr("A".unicode_at(0) + index)))
			
			if data["Reset"]: 
				sequenceIDS.append(currentID)
		
		"Selector Node":
			# Makes the Selector Node and Adds all the Valid Nodes to the Selector
			node = SelectorNode.new()
			for index in data["Nodes"].size():
				if data["Nodes"][index] != null:
					node.append_node(await build_tree(data["Nodes"][index], currentID, String.chr("A".unicode_at(0) + index)))
		
		"Process Node":
			# Makes the Process Node and Adds all the Valid Nodes to the Process
			node = ProcessNode.new(data["Simultaneous"], data["EndOnFirstFail"])
			for index in data["Nodes"].size():
				if data["Nodes"][index] != null:
					node.append_node(await build_tree(data["Nodes"][index], currentID, String.chr("A".unicode_at(0) + index)))
		
		"Delay Node":
			# Makes a Delay Node with the Appropriate Delay Length
			node = DelayNode.new(data["Delay"], get_tree())
	
	# Stores the branch in the branchDef object
	if !isRoot:
		var length = currentID.length()
		if !branchDef.has(length):
			branchDef[length] = []
		
		branchDef[length].append({"ID": currentID, "Node": node})
	
	# Returns the node
	return node

# Goes through all Sequence Nodes and adds their blocking nodes
func add_sequence_blocking_nodes():
	# For Each Sequence Node
	for id in sequenceIDS:
		# Get the Sequence Node
		var idLength = id.length()
		var sequenceNode : SequenceNode
		for node in branchDef[idLength]:
			if node["ID"] == id:
				sequenceNode = node["Node"]
				break
		
		# For Each Length
		for i in range(idLength, 0, -1):
			# For Each Node In Length
			for node in branchDef[i]:
				# If the id's don't match, then add as a blocking node
				if node["ID"] != id:
					sequenceNode.add_blocking_node(node["Node"])
					print(node)
			
			id = id.erase(id.length() - 1)


# Defines the list of variables, based on the data type. Used to Create Vector2 and Vector3 From the Data
func define_variable_list(data):
	var dataList = []
	
	for d in data:
		match d["type"]:
			5:
				dataList.append(Vector2(d["data"]["X"], d["data"]["Y"]))
			9:
				dataList.append(Vector3(d["data"]["X"], d["data"]["Y"], d["data"]["Z"]))
			_:
				dataList.append(d["data"])
	
	return dataList
