extends TreeNode
class_name ProcessNode

# Fields
var associatedNodes : Array[TreeNode]
var threads : Array[Thread]
var results : Array[TreeNode.RESULT]
var isSimultaneous : bool

#Functions
# Init Function
func _init(simul : bool):
	isSimultaneous = simul

# Adds an associated node and preps the arrays for use
func append_node(node : TreeNode):
	associatedNodes.append(node)
	threads.append(Thread.new())
	results.append(TreeNode.RESULT.FAILED)

# Processes the Node
func node_process():
	startedSignal.emit()
	
	var result = TreeNode.RESULT.FAILED
	var successCount = 0
	
	# If Simultaneous, Use Threads
	if isSimultaneous:
		for index in associatedNodes.size():
			threads[index].start(associatedNodes[index].node_process)
		
		for index in associatedNodes.size():
			results[index] = await threads[index].wait_to_finish()
			if results[index] == TreeNode.RESULT.SUCCESS:
				successCount += 1
	# If not Simultaneous, Run one at a Time
	else:
		for index in associatedNodes.size():
			results[index] = await associatedNodes[index].node_process()
			if results[index] == TreeNode.RESULT.SUCCESS:
				successCount += 1
	
	if successCount == associatedNodes.size():
		result = TreeNode.RESULT.SUCCESS
	
	finishedSignal.emit()
	return result
