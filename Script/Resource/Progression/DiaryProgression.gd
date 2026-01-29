class_name DiaryProgression extends BaseProgression

enum BeginWith { NEW_PARAGRAPH, APPEND }

@export var begin_with: BeginWith = BeginWith.APPEND
@export_multiline var text: String = ""

var length = text.length()
var letter_idx: int

func next_letter() -> String:
	if letter_idx >= length: return ""

	var letter = text[letter_idx]
	letter_idx += 1
	return letter


func _init_dependencies(dependencies: Dictionary):
	pass
