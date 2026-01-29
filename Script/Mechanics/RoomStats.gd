class_name RoomStats extends Node

enum RoomLight{ TV, DOOR, WINDOW, LAPTOP }

@export var player_stat_node: PlayerStats = null
@export_range(0.01, 3.0) var slow_tick_ms: float = 1.5
@export_range(0.01, 3.0) var fast_tick_ms: float = 0.5
@export var dark_meter: int = 10

@export_group("Light Value")
@export var tv_light: int = 6
@export var door_light: int = 7
@export var window_light: int = 3
@export var laptop_light: int = 2

@export_group("Room Interactables")
@export var door: DoorBehavior = null
@export var tv: TvBehavior = null
@export var window: WindowBehavior = null

var activate: bool = false
var light: int = 0;
var tick_timer: float
var tick_time: float

func _ready() -> void:
	assert(player_stat_node)
	assert(door)
	assert(tv)
	assert(window)

# [deprecate]
# func update_room_state(from: RoomLight, is_active: bool):
# 	assert(false, "This function needs to be removed")

# 	if is_active:
# 		match from:
# 			RoomLight.TV:
# 				light += tv_light;
# 			RoomLight.DOOR:
# 				light += door_light;
# 			RoomLight.WINDOW:
# 				light += window_light;
# 			RoomLight.LAPTOP:
# 				light += laptop_light

# 	else:
# 		match from:
# 			RoomLight.TV:
# 				light -= tv_light;
# 			RoomLight.DOOR:
# 				light -= door_light;
# 			RoomLight.WINDOW:
# 				light -= window_light;
# 			RoomLight.LAPTOP:
# 				light -= laptop_light

# 	if light < 0: light = 0

# 	self._check_safe_light()

func _fetch_light_update():
	var light = 0;
	if door.open: light += door_light
	if tv.on: light += tv_light
	if window.is_open: light += window_light

	self.light = light
	_update_tick_meter()

func _update_tick_meter():
	if light <= dark_meter:
		var speed = inverse_lerp(0, dark_meter, light)
		tick_time = lerp(fast_tick_ms, slow_tick_ms, speed)

func _check_safe_light():
	if light <= dark_meter:
		if !activate:
			tick_timer = tick_time
			activate = true
	else:
		activate = false



func _physics_process(delta: float) -> void:
	_fetch_light_update()
	_check_safe_light()

	if activate:
		tick_timer -= delta
		if tick_timer <= 0.:
			player_stat_node.tick_sanity()
			tick_timer = tick_time
