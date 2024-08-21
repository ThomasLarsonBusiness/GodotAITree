@tool
extends GraphNode
class_name DelayGraphNode

# Fields
var inputUsed : bool = false
var delayText : TextEdit
var providedData : Dictionary = {}

# Methods
func _ready():
	delayText = get_node("HBoxContainer/Delay Length")
	
	if providedData != {}:
		load_data()




func load_data():
	delayText.text = str(providedData["Delay"])



# Update where the input is being used
func update_input(value : bool):
	inputUsed = value

# Check if the input is being used
func check_input() -> bool:
	return !inputUsed

# When the node is deleted. WHILE IT DOES NOTHING, IS CALLED BY MAIN PANEL. Move to BASE CLASS
func delete_node(graph : GraphEdit):
	pass

# Saves the Data for the Node
func save():
	return {
		"Type": "Delay Node",
		"Position": {
			"X": position_offset.x as int,
			"Y": position_offset.y as int
		},
		"Delay": float(delayText.text)
	}
