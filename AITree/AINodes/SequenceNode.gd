extends TreeNode
class_name SequenceNode

# Fields
var resetOnMiss : bool
var associatedNodes : Array[TreeNode]
var sequenceIndex : int = 0

# Constructor
func _init(reset : bool = true):
	resetOnMiss = reset

# Functions
func append_item_to_sequence(node : TreeNode):
	associatedNodes.append(node)

# Adds a blocking node, marking which nodes trigger a reset on this sequence node
func add_blocking_node(node : TreeNode):
	if resetOnMiss: node.startedSignal.connect(reset_index)

# Process the Node
func node_process():
	startedSignal.emit()
	
	var result = TreeNode.RESULT.FAILED
	
	# Run Next in Sequence
	sequenceIndex += 1
	result = await associatedNodes[sequenceIndex - 1].node_process()
	if sequenceIndex == associatedNodes.size():
		reset_index()
	
	finishedSignal.emit()
	return result

# Resets the index
func reset_index():
	sequenceIndex = 0
