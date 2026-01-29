@tool
class_name ScriptResource extends Resource

var top: int = 0;

@export var lines: Array[LineResource] = []:
	set(val):
		lines = val
		notify_property_list_changed()


func next() -> LineResource:
	if top >= lines.size(): return null;

	var string: LineResource = lines.get(top);
	top += 1;
	return string
