extends Control

@export_range(0.5,5.0, 0.1) var line_time_limit: float = 1.;
@export var dialogue_resource: ScriptResource = null
@export var label_node: DialogueLabel = null

var open_action: bool = false
var passed_time: float = 1.;

var starting: bool = true;

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event.is_action_pressed("ui_accept"):
		play_next_line()

func play_next_line() -> void:
	if !open_action: return
	var next_line: String = dialogue_resource.next();

	if next_line.is_empty():
		self.set_physics_process(false)
		label_node.text = ""
	else:
		label_node.display_new_line(next_line)
		open_action = false;
		self.set_physics_process(false)

# linked by signal
func _line_fully_displayed():
	open_action = true;


# idle timer
func _begin_idle_timer():
	if starting: return
	passed_time = line_time_limit
	self.set_physics_process(true)

func _physics_process(delta: float) -> void:
	passed_time -= delta;
	print("Idle time - ", passed_time)
	if passed_time <= 0.:
		play_next_line()
		self.set_physics_process(false)
		starting = false


func _ready() -> void:
	assert(dialogue_resource);
	assert(label_node);

	label_node.ready_interactable.connect(_line_fully_displayed)
	label_node.ready_interactable.connect(_begin_idle_timer)
	label_node.set_physics_process(true)
