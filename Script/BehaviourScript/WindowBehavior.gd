class_name WindowBehavior extends BaseBehavior

signal window_state_changed(is_open: bool)


@export var model: Node3D = null
@export_range(0.01, 2.0, 0.01) var weight: float = 1.
@export var z_target: float = 0.


var closed: bool = false:
	set(val):
		if val == closed: return
		closed = val
		window_state_changed.emit(val)
		# emit some update for mechanic state - EnemyEntity

var active: bool = false:
	set(val):
		active = val

var is_open: bool = true

var progress_range: float = 0.  # range 0.0 - 1.0
var locked: bool = false

var _origin_position: float = 0.
var _z_target_position: float = 0.

func _ready():
	assert(model)

	_origin_position = model.transform.origin.z
	_z_target_position = _origin_position + z_target


func _lock_curtains():
	pass

func call_trigger():
	pass

func enable_trigger():
	if locked:
		pass

	active = true
	is_open = false
	self.set_physics_process(true)

func disable_trigger():
	if locked: return
	active = false


func hovered_reference():
	pass

func _progress_complete():
	closed = true

func _update_model():
	model.transform.origin.z = lerp(_origin_position, _z_target_position, progress_range);

func _physics_process(delta: float) -> void:
	if active:
		progress_range = min(1., progress_range + (delta * weight))
		if progress_range >= 1.:
			_progress_complete();

	else:
		closed = false
		progress_range = max(0., progress_range - delta)
		if progress_range <= 0.:
			self.set_physics_process(false)
			active = false
			is_open = true

	_update_model()
