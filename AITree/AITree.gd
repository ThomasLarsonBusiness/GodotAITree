@tool
extends EditorPlugin

# Fields
const MainPanel = preload("res://addons/AITree/Main Panel.tscn")
var mainPanelInstance

# When the Plugin Enters the Tree
func _enter_tree():
	# Get the Main Panel Set Up
	mainPanelInstance = MainPanel.instantiate()
	EditorInterface.get_editor_main_screen().add_child(mainPanelInstance)
	_make_visible(false)
	
	# Add the AI Node
	add_custom_type("AITree", "Node2D", preload("res://addons/AITree/AITreeNode/AITreeNode.gd"), preload("res://icon.svg"))

# When the Plugin Exits the Tree
func _exit_tree():
	# Remove the Main Panel
	if mainPanelInstance:
		mainPanelInstance.queue_free()
	
	# Remove Custom Nodes
	remove_custom_type("AITree")

# Returns that this should be in the main screen
func _has_main_screen():
	return true

# Updates the Plugin's Visiblity
func _make_visible(visible):
	if mainPanelInstance:
		mainPanelInstance.visible = visible

# Returns the Plugin's Name
func _get_plugin_name():
	return "AI Tree"

# Returns the Plugin's Icon
func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
