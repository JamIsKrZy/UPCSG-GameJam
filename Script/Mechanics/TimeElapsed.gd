class_name TimeElapsed extends Node

@export var start_hour: int
@export var start_minute: int

@export var end_hour: int
@export var end_minute: int

@export var delta_time_ms: float = 5.
@export_range(0.0,1.0,0.01) var bonus_speed_up: float = 0.75

var time_interval: SceneTreeTimer = null
var hour: int = start_hour
var minute: int = start_minute

# time for accelerating the time duration
# this can be added if player do some laptop
# work or bonus
var owe_time: int;

func _ready():
	hour = start_hour
	minute = start_minute
	_new_time_interval();

func _new_time_interval():

	var timer = get_tree().create_timer(delta_time_ms, true, true)
	timer.timeout.connect(_tick_time)
	time_interval = timer

func _tick_time():

	minute += 1;
	if minute >= 60:
		hour += 1;
		minute = 0

	_new_time_interval()


func add_owe_time(points: int):
	pass

func sub_owe_time(points: int):
	owe_time = max(0, owe_time - points)
