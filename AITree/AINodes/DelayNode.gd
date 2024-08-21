extends TreeNode
class_name DelayNode

# Fields
var delayLength : float = 0.0
var timer : Timer
var treeRef : SceneTree

# Methods
func _init(delay : float, tree : SceneTree):
	delayLength = delay
	treeRef = tree

func node_process():
	startedSignal.emit()
	
	await treeRef.create_timer(delayLength).timeout
	
	finishedSignal.emit()
	return TreeNode.RESULT.SUCCESS
