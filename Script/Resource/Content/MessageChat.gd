@tool
class_name MessageChat extends Resource
enum ChatWho{ Person, You }

@export var who: ChatWho = ChatWho.You
@export var is_image: bool = false:
	set(val):
		is_image = val
		notify_property_list_changed()

var text: String = "Undefined Text, Please Define"
var image: Texture2D = null

func is_you() -> bool:
	return who == ChatWho.You

func _get_property_list() -> Array[Dictionary]:
	var list: Array[Dictionary] = []

	if is_image:
		list.append({
			"name": "image",
			"type": TYPE_OBJECT,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string": "Texture2D",
			"usage": PROPERTY_USAGE_DEFAULT
		})
	else:
		list.append({
			"name": "text",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_MULTILINE_TEXT,
			"usage": PROPERTY_USAGE_DEFAULT
		})

	return list
