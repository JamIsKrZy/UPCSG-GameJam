class_name DialogueLabel extends Label

@export_range(0.01,0.1,0.001) var ms_per_text: float = 0.05
var passed_time: float = 0.0
var max_character: int = 0;

signal ready_interactable;

func _ready() -> void:
	self.set_physics_process(false)
	self.visible_characters = 0;
	self.visible = false

func display_new_line(line: String) -> void:
	if self.is_processing(): return

	self.visible_characters = 0;

	max_character = line.length()
	passed_time = ms_per_text
	self.set_physics_process(true)
	self.visible = true
	self.text = line


func _physics_process(delta: float) -> void:
	passed_time -= delta;
	if passed_time <= 0:
		var char_count: int = self.visible_characters + 1
		self.visible_characters = char_count;

		if char_count >= max_character:
			self.set_physics_process(false)
			ready_interactable.emit()
		passed_time = ms_per_text
