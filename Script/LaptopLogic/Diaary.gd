class_name Diaary extends CharacterBody2D

signal done_typing();

@export var type_per_ms: float = 0.1
@export_range(0.001, 0.5, 0.001) var time_bonus_per_letter: float = 0.075
@onready var text_label: Label = $Control/TextField/ScrollContainer/Label
@onready var scrollContainer: ScrollContainer = $Control/TextField/ScrollContainer


var bonus_accumulator: float = 0.
var letter_timer: float
var _is_typing: bool = false
var _ready_type = false

func _increment_letter_show():
	bonus_accumulator += time_bonus_per_letter
	text_label.visible_characters += 1
	scrollContainer.scroll_vertical = int(scrollContainer.get_v_scroll_bar().max_value)


func _release_bonus_points():
	print("Bonus: ", int(bonus_accumulator))
	bonus_accumulator = 0.


func append_content(content: DiaryContent):
	if content.new_paragraph:
		text_label.text = text_label.text + "\n\n" + content.content
	else:
		text_label.text = content.content


func guide_player(show_guide: bool):
	assert(false, "Undefined Logic: Dev havent handled the logic")
	pass
























var draggingDistance
var dir
var dragging
var newPosition = Vector2()


var _mouse_in_tab = false

@export_category("Window Attributes")
@export var use_screen_boundaries = false
@export var boundary_margin = 3  # Pixels from screen edge
@export var use_collision_check = true  # Check for StaticBody2D collisions


func _ready():
	text_label.text = ""
	text_label.visible_characters = 0
	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() && _mouse_in_tab:
			draggingDistance = position.distance_to(get_viewport().get_mouse_position())
			dir = (get_viewport().get_mouse_position() - position).normalized()
			dragging = true
			newPosition = get_viewport().get_mouse_position() - draggingDistance * dir
		else:
			dragging = false
			#
	elif event is InputEventMouseMotion:
		if dragging:
			newPosition = get_viewport().get_mouse_position() - draggingDistance * dir

	if _ready_type:
		if event.is_action_pressed("ui_accept"):
			_is_typing = true
			letter_timer = type_per_ms
		elif event.is_action_released("ui_accept"):
			_is_typing = false
	else:
		_is_typing = false



func _physics_process(delta):
	if dragging:
		var target_position = newPosition

		# Apply screen boundaries if enabled
		if use_screen_boundaries:
			target_position = clamp_to_screen(target_position)

		# Calculate velocity
		velocity = (target_position - position) * Vector2(30, 30)

		# Move and check for collisions
		move_and_slide()

		# If collision check is enabled, prevent movement into walls
		if use_collision_check && get_slide_collision_count() > 0:
			# Get the last valid position before collision
			for i in get_slide_collision_count():
				var collision = get_slide_collision(i)
				# Push back slightly from the collision
				position -= collision.get_normal() * 2

	if _is_typing:
		letter_timer -= delta
		if letter_timer < 0.:
			_increment_letter_show()
			letter_timer = type_per_ms




func clamp_to_screen(target_pos: Vector2) -> Vector2:
	var screen_size = get_viewport_rect().size
	var clamped_pos = target_pos

	clamped_pos.x = clamp(target_pos.x, boundary_margin, screen_size.x - boundary_margin)
	clamped_pos.y = clamp(target_pos.y, boundary_margin, screen_size.y - boundary_margin)

	return clamped_pos

func _mouse_entered_tab() -> void:
	_mouse_in_tab = true

func _mouse_exited_tab() -> void:
	_mouse_in_tab = false

func _mouse_entered_text_field():
	_ready_type = true

func _mouse_exited_text_field():
	_ready_type = false
