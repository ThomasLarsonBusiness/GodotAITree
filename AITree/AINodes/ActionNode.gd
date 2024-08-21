extends TreeNode
class_name ActionNode

# Fields
var callableObject : Object
var callableName : StringName
var variableList : Array = []

# Functions
func assign_callable(object : Object, name : StringName, variables : Array = []):
	callableObject = object
	callableName = name
	if variables != []:
		variableList = variables

# Processes the Node
func node_process():
	startedSignal.emit()
	
	var result = TreeNode.RESULT.FAILED
	
	# Calls the Assigned Function, Providing the Variables
	if callableObject != null:
		result = await callableObject.callv(callableName, variableList)
	
	finishedSignal.emit()
	return result
