@tool
extends GraphNode
class_name ActionGraphNode

# Fields
@onready var callableOptions = get_node("FunctionDefinition/CallableOptions")

var inputUsed : bool = false
var arrayOfMethods : Array[String] = []
var methodIndecies : Array[int] = []
var varTypeArray : Array[int] = []
var providedData : Dictionary = {}

# On Ready, defines and gets all necessary elements
func _ready():
	# Clears items to prevent cached items
	callableOptions.clear()
	arrayOfMethods.clear()
	
	# If inside the tree, get the method list
	if is_inside_tree():
		var methodList = get_tree().edited_scene_root.get_script().get_script_method_list()
		for i in methodList.size():
			if methodList[i]["name"].left(1) == "@" or methodList[i]["return"]["class_name"] != "TreeNode.RESULT":
				#indexDifference += 1
				continue
			
			var name = methodList[i]["name"]
			arrayOfMethods.append(name)
			methodIndecies.append(i)
			callableOptions.add_item(name)
	
	# If data exists, Load the data into the Node
	if providedData != {}:
		load_data()

# When an obtion is selected, get the list of variables
func _on_callable_options_item_selected(index):
	# Gets the method description
	var selectedMethod = get_tree().edited_scene_root.get_script().get_script_method_list()[methodIndecies[index]]
	
	# Remove All Variables
	for i in get_children():
		if i.name != "FunctionDefinition":
			i.queue_free()
	
	# Create New Variables
	varTypeArray.clear()
	selectedMethod["args"].reverse()
	for i in selectedMethod["args"]:
		add_variable(i["name"], i["type"])
	varTypeArray.reverse()

# List of Variant Types
# [Bool = 1, int = 2, float = 3, string = 4, Vector2 = 5, Vector3 = 9]

# Adds a variable editor to the node
func add_variable(variableName : String, variantType : int):
	# Add HBoxContainer
	var variableRoot = HBoxContainer.new()
	$FunctionDefinition.add_sibling(variableRoot)
	
	# Add the Label
	var nameLabel = Label.new()
	nameLabel.custom_minimum_size = Vector2(120, 35)
	nameLabel.text = variableName.capitalize()
	nameLabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	variableRoot.add_child(nameLabel)
	
	# Create an editor based on the variable type
	match variantType:
		# Boolean
		1:
			var varEdit = CheckBox.new()
			varEdit.custom_minimum_size = Vector2(35,35)
			varEdit.size_flags_horizontal = Control.SIZE_SHRINK_END
			variableRoot.add_child(varEdit)
		# Integer
		2:
			var varEdit = TextEdit.new()
			varEdit.custom_minimum_size = Vector2(120, 35)
			varEdit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			variableRoot.add_child(varEdit)
		# Float
		3:
			var varEdit = TextEdit.new()
			varEdit.custom_minimum_size = Vector2(120, 35)
			varEdit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			variableRoot.add_child(varEdit)
		# String
		4:
			var varEdit = TextEdit.new()
			varEdit.custom_minimum_size = Vector2(120, 35)
			varEdit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			variableRoot.add_child(varEdit)
		# Vector 2
		5:
			var xEdit = TextEdit.new()
			xEdit.custom_minimum_size = Vector2(60, 35)
			xEdit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			variableRoot.add_child(xEdit)
			
			var yEdit = TextEdit.new()
			yEdit.custom_minimum_size = Vector2(60, 35)
			yEdit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			variableRoot.add_child(yEdit)
		# Vector 3
		9:
			var xEdit = TextEdit.new()
			xEdit.custom_minimum_size = Vector2(40, 35)
			xEdit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			variableRoot.add_child(xEdit)
			var yEdit = TextEdit.new()
			yEdit.custom_minimum_size = Vector2(40, 35)
			yEdit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			variableRoot.add_child(yEdit)
			var zEdit = TextEdit.new()
			zEdit.custom_minimum_size = Vector2(40, 35)
			zEdit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			variableRoot.add_child(zEdit)
	
	# Adds the Type to the Type Array for Saving
	varTypeArray.append(variantType)

# Loads in the Data Provided to the Node
func load_data():
	# Sets the Correct Action
	for index in callableOptions.item_count:
		if callableOptions.get_item_text(index) == providedData["CallableID"]:
			callableOptions.select(index)
			_on_callable_options_item_selected(index)
			break
	
	# If there are variables, update them
	if providedData["Variables"].size() > 0:
		var vars = providedData["Variables"]
		var children = get_children()
		children.remove_at(0)
		
		# Sets the data based on the variable types
		for i in vars.size():
			match varTypeArray[i]:
				# Boolean
				1:
					children[i].get_child(1).button_pressed = vars[i]["data"]
				# Integer
				2:
					children[i].get_child(1).text = str(vars[i]["data"])
				# Float
				3:
					children[i].get_child(1).text = str(vars[i]["data"])
				# String
				4:
					children[i].get_child(1).text = vars[i]["data"]
				# Vector 2
				5:
					children[i].get_child(1).text = str(vars[i]["data"]["X"])
					children[i].get_child(2).text = str(vars[i]["data"]["Y"])
				# Vector 3
				9:
					children[i].get_child(1).text = str(vars[i]["data"]["X"])
					children[i].get_child(2).text = str(vars[i]["data"]["Y"])
					children[i].get_child(3).text = str(vars[i]["data"]["Z"])

# CAN BE DELETED?
func _on_delete_pressed(root : Node):
	root.queue_free()

# Update where the input is being used
func update_input(value : bool):
	inputUsed = value

# Check if the input is being used
func check_input() -> bool:
	return !inputUsed

# When the node is deleted. WHILE IT DOES NOTHING, IS CALLED BY MAIN PANEL. Move to BASE CLASS
func delete_node(graph : GraphEdit):
	pass

func save():
	# Grab the Variable Data
	var variableData = []
	var children = get_children()
	children.remove_at(0)
	if children != []:
		for i in children.size():
			var thisData = {
				"name": children[i].get_child(0).text,
				"type": varTypeArray[i]
			}
			
			match varTypeArray[i]:
				1:
					thisData["data"] = children[i].get_child(1).button_pressed
				2:
					thisData["data"] = int(children[i].get_child(1).text)
				3:
					thisData["data"] = float(children[i].get_child(1).text)
				4:
					thisData["data"] = children[i].get_child(1).text
				5:
					thisData["data"] = {
						"X": float(children[i].get_child(1).text),
						"Y": float(children[i].get_child(2).text)
					}
				9:
					thisData["data"] = {
						"X": float(children[i].get_child(1).text),
						"Y": float(children[i].get_child(2).text),
						"Z": float(children[i].get_child(3).text)
					}
				_:
					continue
			
			variableData.append(thisData)
	
	return {
		"Type": "Action Node",
		"Position": {
			"X": position_offset.x as int,
			"Y": position_offset.y as int
		},
		"CallableID": callableOptions.get_item_text(callableOptions.selected),
		"Variables": variableData
	}
