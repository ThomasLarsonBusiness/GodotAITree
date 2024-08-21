extends TreeNode
class_name RandomNode

# Fields
var associatedNodes : Array[TreeNode]
var nodeWeights : Array[float]
var nodeWeightCombo : float
var rng : RandomNumberGenerator

# Fields to add exclusive
var isExclusive : bool
var nodeActive : Array[bool]

# Constructor
func _init(_exclusive : bool):
	rng = RandomNumberGenerator.new()
	isExclusive = _exclusive

# Functions
# Adds a node as a child of this node
func add_node(node : TreeNode, weight : float):
	associatedNodes.append(node)
	nodeWeights.append(weight)
	nodeWeightCombo += weight
	
	# For Exclusive Random
	nodeActive.append(false)
	node.startedSignal.connect(lock_active.bind(node))
	node.finishedSignal.connect(free_active.bind(node))

# Updates the nodeActive state to mark start
func lock_active(node : TreeNode):
	var index = associatedNodes.find(node)
	nodeActive[index] = true

# Updates the nodeActive state to mark completion
func free_active(node : TreeNode):
	var index = associatedNodes.find(node)
	nodeActive[index] = false

# Processes the Node
func node_process():
	startedSignal.emit()
	
	var result = TreeNode.RESULT.FAILED
	
	# Defines the range of weights
	var openActions : Array[TreeNode]
	var adjustedWeight : float = nodeWeightCombo
	
	if isExclusive:
		adjustedWeight = 0.0
		for i in associatedNodes.size():
			if !nodeActive[i]:
				openActions.append(associatedNodes[i])
				adjustedWeight += nodeWeights[i]
			else:
				openActions.append(null)
	
	# Gets the random number
	var randomNum = rng.randf_range(0.0, adjustedWeight)
	
	# Compares against the weights of the weight list
	var curWeightTotal = 0.0
	for i in nodeWeights.size():
		if isExclusive and openActions[i] == null:
			continue
		curWeightTotal += nodeWeights[i]
		if randomNum <= curWeightTotal:
			result = await associatedNodes[i].node_process()
			break
	
	finishedSignal.emit()
	return result
	
