@tool
class_name DoorEntity01 extends PathFollow3D

@onready var entity_node = get_node("Entity")

func _ready():

	assert(entity_node)

func get_entity_node():
	return entity_node
