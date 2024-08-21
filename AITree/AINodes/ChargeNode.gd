extends TreeNode
class_name ChargeNode

# Fields
var function : Callable
var nodeOnSuccess : TreeNode
var nodeOnFail : TreeNode

# Constructor
func _init(callback : Callable, passNode : TreeNode, failNode : TreeNode = null):
	# Assigns the Function
	function = callback
	nodeOnSuccess = passNode
	
	# If a fail signal is passed in, setup the fail variables
	if failNode != null:
		nodeOnFail = failNode

# Functions
func node_process():
	startedSignal.emit()
	
	# Run the callback function
	var result : bool = await function.call()
	
	# If result is false and node exists, run Fail Node
	if !result and nodeOnFail != null:
		nodeOnFail.node_process()
		finishedSignal.emit()
	else:
		await nodeOnSuccess.node_process()
		finishedSignal.emit()
	
	
