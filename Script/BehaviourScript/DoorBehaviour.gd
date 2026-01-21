class_name DoorBehavior extends BaseBehavior


signal door_toggled(is_open: bool)

@export var model: Node3D = null
@export var open: bool = true

var locked: bool = false


func _update_model():
	pass


func lock_door(duration: float):
	locked = true
	var timer = get_tree().create_timer(duration, true, true);
	timer.timeout.connect(func():
		self.locked = false
	)


func call_trigger():
	if locked:
		pass

	open = !open;
	door_toggled.emit(open)
	_update_model()

func enable_trigger():
	pass

func disable_trigger():
	pass


func hovered_reference():
	pass


func _ready():
	assert(model)

	_update_model()
