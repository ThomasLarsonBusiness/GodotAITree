extends TreeNode
class_name ConditionalNode

# Fields
var falseNode : TreeNode
var trueNode : TreeNode
var parentNode : Node
var booleanName : StringName

# Functions
func _init(name : StringName = "", node : Node = null):
	booleanName = name
	parentNode = node

# Processes the Node
func node_process():
	startedSignal.emit()
	
	var result = TreeNode.RESULT.FAILED
	
	var value = parentNode.get(booleanName)
	
	if value and trueNode:
		result = await trueNode.node_process()
	elif !value and falseNode:
		result = await falseNode.node_process()
	
	print(TreeNode.RESULT.keys()[result])
	
	finishedSignal.emit()
	return result
