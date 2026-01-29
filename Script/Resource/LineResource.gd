@tool
class_name LineResource extends Resource

@export var use_prev_color: bool = false:
	set(val):
		use_prev_color = val
		notify_property_list_changed()

var set_color: bool = false:
	set(val):
		set_color = val
		notify_property_list_changed()

var color: Color = Color(0.,0.,0.)
@export_multiline var line: String = ""

func _get_property_list() -> Array[Dictionary]:
	var list: Array[Dictionary] =[]


	if use_prev_color: return list;

	list.push_back({
		"name": "set_color",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT,
	})

	if set_color: list.push_back({
		"name": "color",
		"type": TYPE_COLOR,
		"usage": PROPERTY_USAGE_DEFAULT,
	})
	return list
