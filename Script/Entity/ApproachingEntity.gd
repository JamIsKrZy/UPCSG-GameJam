class_name ApproachingEntity extends BaseEntity


var _approach_time: float;
var approach_progress: float:
	set(val):
		approach_progress = val
		attack_meter = inverse_lerp(0., _approach_time, approach_progress)

var _closed_duration: float;
var _closed_progress: float = 0.;
var _closed: bool = false

func _init(
	type: EntityManager.Entity,
	closed_duration: float,
	approach_time: float,
	door_is_open: bool
) -> void:
	self.type = type
	_closed_duration = closed_duration
	_approach_time = approach_time
	approach_progress = 0.
	_closed = !door_is_open


func door_shut():
	_closed = true
	pass

func door_open():
	_closed = false
	_closed_progress = 0.


# will be executed by a holder physics process
func process(delta: float):
	if _closed:
		_closed_progress += delta
		if _closed_progress >= _closed_duration:
			leave()

	approach_progress = min(_approach_time, delta + approach_progress)
	if approach_progress >= _approach_time and not _closed:
		attack()
