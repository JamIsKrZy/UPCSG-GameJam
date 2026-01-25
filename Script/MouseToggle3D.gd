class_name MouseToggle extends Area3D

# these objects must contain a function name "call_trigger()"
@export var hold_and_release: bool = false
@export var call_objects: Array[BaseBehavior] = []

var on_hold: bool = false
var lock = false

# any indiicator for clickable
# set mouse poiinter
# highlight object
func _on_mouse_entered() -> void:
	pass

func _on_mouse_exit() -> void:
	if on_hold:
		on_hold = false
		disable_objects()




func call_object_triggers():
	for obj in call_objects:
		obj.call_trigger()

func enable_objects():
	for obj in call_objects:
		obj.enable_trigger()

func disable_objects():
	for obj in call_objects:
		obj.disable_trigger()

func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and not lock:


		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				print("[Mouse Input - ", self.name,"] ClICK")

				if hold_and_release:
					on_hold = true
					enable_objects()
				else:
					call_object_triggers()

			elif hold_and_release:
				print("[Mouse Input - ", self.name,"] RELEASE")
				disable_objects()
				on_hold = false

func _ready() -> void:
	self.input_event.connect(_on_input_event)
	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exit)


func _unlock_input_listen():
	lock = false

func _laptop_slot_interacted(is_active: bool) -> void:
	lock = is_active
