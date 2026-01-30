class_name TimeElapsed extends Node

@export var start_hour: int
@export var start_minute: int

@export var end_hour: int
@export var end_minute: int

@export var delta_time_ms: float = 5.
@export_range(0.0,1.0,0.01) var bonus_speed_up: float = 0.75

@export_group("On time Event")
@export var messages: Array[TimeBoundMessageThread] = []
@export var medias: Array[TimeBoundMessageThread] = []

@export_group("Sun Position")
@export var sun: DirectionalLight3D = null
@export var _from: float = 0.
@export var _to: float = 0.

@export_group("Dependent")
@export var laptop: MainLaptop = null
@export var clock_label: Label = null


var time_interval: SceneTreeTimer = null
var hour: int = start_hour
var minute: int = start_minute

# time for accelerating the time duration
# this can be added if player do some laptop
# work or bonus
var owe_time: int;

var c_start_time: int
var c_end_time: int
var _sun_chase: float
var _sun_angle: float

static func computed_time(hour: int, minute: int) -> int:
	return (hour * 60) + minute

func _process_sun_chase(delta: float):
	_sun_chase = lerp(
		_sun_chase,
		_sun_angle,
		1.0 - exp(-1. * delta)
	)

func compute_sun_angle():
	_sun_angle = TimeElapsed.computed_time(self.hour, self.minute)


func _ready():
	assert(sun)
	assert(laptop)
	assert(clock_label)
	_assert_time_events()

	hour = start_hour
	minute = start_minute
	c_start_time = TimeElapsed.computed_time(self.start_hour, self.start_minute)
	c_end_time = TimeElapsed.computed_time(self.end_hour, self.end_minute)
	_sun_chase = c_start_time
	_new_time_interval();

func _assert_time_events():
	for event in messages:
		if event.beyond_time(start_hour, start_minute):
			assert(false, "TimeEvent is out of bounds, check call stack")

func _new_time_interval():
	var timer = get_tree().create_timer(delta_time_ms, true, true)
	timer.timeout.connect(_tick_time)
	time_interval = timer



func _process_message_time_events():
	for i in range(messages.size() - 1, -1, -1):
		var message_event = messages[i]
		if message_event.is_on_time(hour, minute):
			messages.remove_at(i)
			print("[ TimeSystem ] Processed an Message event")
			laptop.new_message(message_event.content)


func _process_media_time_events():
	for i in range(medias.size() - 1, -1, -1):
		var media_event = medias[i]
		if media_event.is_on_time(hour, minute):
			medias.remove_at(i)


func _process(delta: float) -> void:
	compute_sun_angle()
	_process_sun_chase(delta)

	var t = inverse_lerp(float(c_start_time), float(c_end_time), _sun_chase)

	sun.rotation.x = deg_to_rad(lerp(_from, _to, t))


func _tick_time():
	minute += 1;
	if minute >= 60:
		hour += 1;
		minute = 0

	_process_message_time_events()
	_process_media_time_events()

	clock_label.text = str(hour) + "\n" + str(minute)

	if hour == end_hour && minute >= end_minute:
		SceneChangeHandler.done_day(laptop.progression_list.is_empty())
		return;

	_new_time_interval()


func add_owe_time(points: int):
	pass

func sub_owe_time(points: int):
	owe_time = max(0, owe_time - points)
