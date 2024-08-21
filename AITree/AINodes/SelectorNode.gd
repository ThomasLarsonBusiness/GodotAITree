extends TreeNode
class_name SelectorNode

# Fields
var associatedNodes : Array[TreeNode]

# Functions
func append_node(node : TreeNode):
	associatedNodes.append(node)

# Process the Node
func node_process():
	startedSignal.emit()
	
	var result = TreeNode.RESULT.FAILED
	
	# Runs Nodes In Order Until Success
	for node in associatedNodes:
		result = await node.node_process()
		if result == TreeNode.RESULT.SUCCESS:
			break
	
	finishedSignal.emit()
	return result
