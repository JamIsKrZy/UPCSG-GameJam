class_name PlayerStats extends Node

@export_group("Heart Rate Stats")
@export var base_heart_rate: float = 150.0
@export var death_heart_rate: float = 200.
@export var heart_rate_cooldown: float= 5.000
@export var hr_up_of_change: float = 1.
@export var hr_down_rate_of_change: float = 1.

@export_subgroup("Effect")
@export var hr_danger: float = 160.
@export var vignette_curve: Curve = null
@export var virtual_heart_rate_speed := 2.0




# Relation to heart rate
# Can affect heart rate
@export_group("Sanity Stats")
@export var base_sanity: float = 0.
@export var peak_sanity: float = 40.
@export var sanity_cooldown_ms_time: float = 2.0
@export_range(0.5, 3.0) var tick_down_ms: float = 1.5
@export var sanity_up_rate_of_change: float = 1.
@export var sanity_down_rate_of_change: float = 1.

# this is an indicator that sanity can decrese
# if it meets the heart rate meter to calm down
@export_subgroup("HeartRate Relation")
@export var sanity_threshold_effect_hr: float = 25.
@export var hr_tick_per_ms: float = 0.8

@export_subgroup("Effect")
@export var sanity_danger: float = 20.
@export var virtual_sanity_speed := 6.0

@export_group("Dependencies")
@export var camera: PhantomCamera3D = null
@export var screen_fx: PostProcessingController

# meter - range 0.0 - 1.0
# used to warning other mechanism nodes such as camerafx
signal sanity_warning(meter: float);
signal hr_warning(meter: float);

# Range 0.0 to 10.0



var _virtual_heart_rate = base_heart_rate
var heart_rate: float:
	set(val):
		if val >= death_heart_rate:
			assert(false, "death!!")
		heart_rate = val
var _hr_tick_timer = hr_tick_per_ms
var _hr_cooldown = heart_rate_cooldown

@onready var sanity_cooldown: float = sanity_cooldown_ms_time
var in_sanity: bool = false
var _sanity_down_timer = tick_down_ms
var _virtual_sanity = 0.
var sanity: float = 0.:
	set(val):
		sanity = min(val, peak_sanity)




var _intensity_falloff_base = 0.

func _ready():
	assert(vignette_curve)
	assert(camera)
	assert(screen_fx)

	_intensity_falloff_base = screen_fx._intensity - (screen_fx._intensity * 0.65)
	heart_rate = base_heart_rate

func tick_sanity():
	in_sanity = true;
	sanity += sanity_up_rate_of_change;
	sanity_cooldown = sanity_cooldown_ms_time;

# tells the player is still doing some activities
# this will reset the heart cooldown timer
func player_doing_action():
	_hr_cooldown = heart_rate_cooldown

func tick_heart_rate():
	heart_rate += hr_up_of_change
	player_doing_action()


# gradually set the heart rate overtime
func set_heart_rate():
	pass



func _process_blur():
	# sanity → intensity (0.0 - 2.0)
	# sanity → intensity (0.0 - 2.0)
	var intensity_meter := inverse_lerp(sanity_danger, peak_sanity, _virtual_sanity)
	intensity_meter = clamp(intensity_meter, 0.0, 1.0)

	screen_fx._intensity = lerp(0.0, 2.0, intensity_meter)

	# intensity threshold → falloff
	var falloff_meter := inverse_lerp(
		1.25,          # start decreasing here
		2.0,           # fully decreased here
		screen_fx._intensity
	)
	falloff_meter = clamp(falloff_meter, 0.0, 1.0)


	screen_fx._falloff = lerp(1.0, 0.05, falloff_meter)


# Relation to heart rate
func _process_camera_shake():
	var meter := inverse_lerp(hr_danger - 40, death_heart_rate, _virtual_heart_rate)
	meter = clamp(meter, 0.0, 1.0)

	camera.noise.frequency = lerp(0.1, 0.5, meter)

var vignette_time := 0.0

# Relation to heart rate
func _process_vignette(delta: float):
	var meter := inverse_lerp(hr_danger, death_heart_rate, _virtual_heart_rate)
	meter = clamp(meter, 0.0, 1.0)

	# Base vignette (curve-controlled)
	var base_radius: float = vignette_curve.sample(1.0 - meter)

	# Time progression
	vignette_time += delta

	# Pulse parameters
	var pulse_speed: float = lerp(1.5, 4.0, meter)
	var pulse_strength: float = lerp(0.0, 0.12, meter)

	# Raw pulse (-1 .. 1)
	var pulse := sin(vignette_time * pulse_speed)

	# Bias pulse so it mostly CLOSES the vignette
	# (0..1 instead of -1..1)
	var biased_pulse := (pulse + 1.0) * 0.5

	# Apply pulse
	var final_radius := base_radius - (biased_pulse * pulse_strength)

	# Safety clamp
	screen_fx._inner_radius = clamp(final_radius, -0.7, 0.7)

func _process(delta: float) -> void:
	_process_virtual_sanity(delta)
	_process_virtual_heart_rate(delta)
	# print(_virtual_sanity)

	_process_blur()
	_process_vignette(delta)
	_process_camera_shake()


func _process_virtual_sanity(delta: float):
	_virtual_sanity = lerp(
		_virtual_sanity,
		sanity,
		1.0 - exp(-virtual_sanity_speed * delta)
	)

func _process_virtual_heart_rate(delta: float):
	_virtual_heart_rate = lerp(
		_virtual_heart_rate,
		heart_rate,
		1. - exp(-virtual_heart_rate_speed * delta)
	)

func _is_death() -> bool:
	return heart_rate >= death_heart_rate

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

	_hr_tick_timer -= delta
	if _hr_cooldown > 0: _hr_cooldown -= delta
	if sanity >= sanity_threshold_effect_hr:
		if _hr_tick_timer <= 0.:
			tick_heart_rate()
			_hr_tick_timer = hr_tick_per_ms

	elif _hr_cooldown <= 0:
		if _hr_tick_timer <= 0.:
			heart_rate = max(base_heart_rate, heart_rate - hr_down_rate_of_change)
			_hr_tick_timer = hr_tick_per_ms

	else:
		_hr_tick_timer = hr_tick_per_ms
