@tool
class_name TimeBoundMediaContent extends Resource

enum Type{ Diary, }

@export var hour: int = 5
@export var minute: int = 0:
	set(val):
		if val >=60 || val < 0: return
		minute = val

@export var content: MediaContent = null
