class_name ScriptResource extends Resource

@export var lines: Array[String] = []
var top: int = 0;

func next() -> String:
	if top >= lines.size(): return "";

	var string: String = lines.get(top);
	top += 1;
	return string
