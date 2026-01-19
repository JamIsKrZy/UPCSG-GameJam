class_name PlayerStats extends Node

@export_group("Heart Rate Stats")
@export var base_heart_rate: float = 89.0
@export var death_heart_rate: float = 200.
@export var hr_up_of_change: float = 1.
@export var hr_down_rate_of_change: float = 1.


@export_group("Sanity Stats")
@export var base_sanity: float = 0.
@export var death_sanity: float = 30
@export var sanity_cooldown_ms_time: float = 2.0
@export_range(0.5, 3.0) var tick_down_ms: float = 1.5
@export var sanity_up_rate_of_change: float = 1.
@export var sanity_down_rate_of_change: float = 1.



# meter - range 0.0 - 1.0
# used to warning other mechanism nodes such as camerafx
signal sanity_warning(meter: float);
signal hr_warning(meter: float);

# Range 0.0 to 10.0


@onready var sanity_cooldown: float = sanity_cooldown_ms_time
var in_sanity: bool = false
var _sanity_down_timer = tick_down_ms
var sanity: float = 0.:
	set(val):
		sanity = val
		# call warning signal
		# TODO:
			#
			#
			#
			#
			#


var heart_rate: float = base_heart_rate


func tick_sanity():
	in_sanity = true;
	sanity += sanity_up_rate_of_change;
	sanity_cooldown = sanity_cooldown_ms_time;



func _physics_process(delta: float) -> void:
	if in_sanity:
		sanity_cooldown = max(0., sanity_cooldown - delta)
		if sanity_cooldown <= 0. :
			in_sanity = false

	else:
		_sanity_down_timer =  _sanity_down_timer - delta
		if _sanity_down_timer <= 0:
			sanity = max( base_sanity, sanity - sanity_down_rate_of_change )
			_sanity_down_timer = tick_down_ms
