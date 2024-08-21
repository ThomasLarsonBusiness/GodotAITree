extends Resource
class_name TreeData

## The data that represents the AI Tree
@export var data : Dictionary

# Creates a blank form of the data if the data does not exist
func _init(_data : Dictionary = {}):
	data = _data
