extends TreeNode
class_name ExclusiveRandomNode

# Fields
var associatedNodes : Array[TreeNode]
var nodeWeights : Array[float]
var nodeActive: Array[bool]
var nodeWeightCombo : float
var rng : RandomNumberGenerator

# Constructor
func _init():
	rng = RandomNumberGenerator.new()

# Functions
# Adds a node as a child of this node
func add_node(node : TreeNode, weight : float):
	associatedNodes.append(node)
	nodeWeights.append(weight)
	nodeActive.append(false)
	node.startedSignal.connect(lock_active.bind(node))
	node.finishedSignal.connect(free_active.bind(node))
	nodeWeightCombo += weight

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
	
	# Gets an array of the available options
	var openActions : Array[TreeNode]
	var openWeights : Array[float]
	var adjustedWeight : float = 0.0
	for i in associatedNodes.size():
		if !nodeActive[i]:
			openActions.append(associatedNodes[i])
			openWeights.append(nodeWeights[i])
			adjustedWeight += nodeWeights[i]
		else:
			openActions.append(null)
			openWeights.append(0.0)
	
	# Gets the random number
	var randomNum = rng.randf_range(0.0, adjustedWeight)
	
	# Picks the randomly selected node
	var curWeightTotal = 0.0
	for i in associatedNodes.size():
		if openActions[i] == null:
			continue
		curWeightTotal += openWeights[i]
		if randomNum <= curWeightTotal:
			await openActions[i].node_process()
			finishedSignal.emit()
			break
