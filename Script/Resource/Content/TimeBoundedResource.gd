@abstract
class_name TimeBoundResource extends Resource

@export var hour: int = 5
@export var minute: int = 0:
	set(val):
		if val >=60 || val < 0: return
		minute = val

func is_on_time(hour: int, minute: int) -> bool:
	return self.hour == hour && minute >= self.minute

func beyond_time(hour: int, minute: int) -> bool:
	return self.hour <= hour && self.minute < minute
