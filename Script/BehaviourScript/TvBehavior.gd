@tool
class_name TvBehavior extends BaseBehavior

signal tv_toggled(is_on: bool)

@export var model: Node3D = null
@export var on: bool = true:
	set(val):
		on = val;
		_update_model()


var locked: bool = false

func lock_tv(duration: float):
	locked = true
	var timer = get_tree().create_timer(duration, true, true);
	timer.timeout.connect(func():
		self.locked = false
	)


func call_trigger():
	if locked:
		pass

	on = !on
	tv_toggled.emit(on)
	_update_model()


func _update_model():
	model.visible = on

	AudioSystem.set_bus_volume("VideoSfx", 1. if on else 0.)


func hovered_reference():
	pass

func enable_trigger():
	pass

func disable_trigger():
	pass


func _ready():
	assert(model)

	_update_model()
