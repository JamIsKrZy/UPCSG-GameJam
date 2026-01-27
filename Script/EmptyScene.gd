extends Control

@export_range(0.5,5.0, 0.1) var line_time_limit: float = 1.;
@export var wait_done_time: float = 3.
@export var label_node: DialogueLabel = null
@export var is_pre_game: bool = true
@export var to_menu: bool = false

var open_action: bool = false
var passed_time: float = 1.;
var dialogue_resource: ScriptResource = null
var starting: bool = true;


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event.is_action_pressed("ui_accept"):
		play_next_line()

func play_next_line() -> bool:
	if !open_action: return false
	var next_line: String = dialogue_resource.next();

	if next_line.is_empty():
		label_node.text = ""
		return true
	else:
		label_node.display_new_line(next_line)
		open_action = false;
		self.set_physics_process(false)
		return false

# linked by signal
func _line_fully_displayed():
	open_action = true;


# idle timer
func _begin_idle_timer():
	if starting: return
	passed_time = line_time_limit
	self.set_physics_process(true)

func _done_scene():
	print("PLAY DAY!!")
	if to_menu:
		SceneChangeHandler.go_to_menu();
	else:
		SceneChangeHandler.play_day();


func _physics_process(delta: float) -> void:
	passed_time -= delta;
	print("Idle time - ", passed_time)
	if passed_time <= 0.:
		var is_done = play_next_line()
		self.set_physics_process(false)
		starting = false


		if is_done:
			var time_wait = get_tree().create_timer(wait_done_time, true, true)
			time_wait.timeout.connect(_done_scene)


func _ready() -> void:
	dialogue_resource = SceneChangeHandler.pre_scene_script if self.is_pre_game else SceneChangeHandler.post_scene_script
	AudioSystem.play_stream_fade_in("BGM","PreGameMusic", 3.)

	assert(dialogue_resource);
	assert(label_node);

	label_node.ready_interactable.connect(_line_fully_displayed)
	label_node.ready_interactable.connect(_begin_idle_timer)
	label_node.set_physics_process(true)
