class_name Messager extends CharacterBody2D

var draggingDistance
var dir
var dragging
var newPosition = Vector2()


var mouse_in = false


@export var use_screen_boundaries = true
@export var boundary_margin = 3  # Pixels from screen edge
@export var use_collision_check = true  # Check for StaticBody2D collisions

@export var ready_threads: Array[MessageThreadContent] = []

@export_group("Link Nodes")
@export var chat_box_texture: TextureRect = null
@export var chat_box_label: Label = null

@onready var account_slots: VBoxContainer = $Control/Panel/ScrollContainer/AccountSlot
@onready var chat_box: VBoxContainer = $Control/ChatBox/ChatContainer/ScrollContainer/MarginContainer/BubbleContainer
@onready var chat_box_scroll: ScrollContainer = $Control/ChatBox/ChatContainer/ScrollContainer
var MessengerScene := preload("res://MainScene/Laptop/MessagerUserThread.tscn")
var ChatBubbleScene := preload("res://MainScene/Laptop/MessageChatBubble.tscn")


var registered_threads: Dictionary[int,RegisteredThread] = {};
var person_id: Dictionary[String, int] = {};

var active_thread: RegisteredThread = null


func _ready():
	assert(account_slots)
	assert(chat_box)

	_empty_chat_box()
	_init_message_threads()




func _init_message_threads():
	var id_counter = 0;
	for thread in ready_threads:
		if thread == null: continue

		if _check_person_is_registered(thread):
			# Some appending stufff to do
			continue

		var slot: MassagerUserThread = MessengerScene.instantiate();
		slot.setup(
			id_counter,
			thread.person,
			thread.recent_message(),
			RegAccounts.get_account_texture(thread.person),
			self
		)

		account_slots.add_child(slot)
		_register_thread(id_counter, thread, slot)
		id_counter += 1;

func _check_person_is_registered(thread: MessageThreadContent) -> bool:
	return person_id.has(thread.person)

func _register_thread(id: int, thread: MessageThreadContent, node: MassagerUserThread):
	person_id[thread.person] = id
	var thread_ref = RegisteredThread.new(thread, node)
	registered_threads[id] = thread_ref




func new_message(thread: MessageThreadContent):

	# Insert it to the messages data structure
	# If its being viewed in screen then insert new chat bubble

	pass

func _get_thread(thread: MessageThreadContent) -> RegisteredThread:
	var id: int = person_id.get(thread.person,-1);
	if id == -1: return null;
	return registered_threads.get(id, null)

# OPens the thread to the chat box
func __open_thread(id: int):
	print("[ MessagerHandler ] Opened ", registered_threads[id].thread.person)
	pass
	var thread_data = registered_threads.get(id, null)
	if thread_data == null:
		printerr("[ MessagerHandler ] Open Thread: No id:", id, " is assigned!")
		return
	_swap_chat_box(thread_data)

	active_thread = thread_data

func _empty_chat_box():
	chat_box_texture.hide()
	chat_box_label.hide()

	for chat_bubble in chat_box.get_children():
		chat_bubble.queue_free()


func _swap_chat_box(thread: RegisteredThread):
	_empty_chat_box()
	chat_box_texture.visible = true
	chat_box_texture.texture = thread.node_thread.get_texture()

	chat_box_label.visible = true
	chat_box_label.text = thread.thread.person

	for message: MessageChat in thread.thread.messages:
		var chat_bubble = ChatBubbleScene.instantiate()
		chat_box.add_child(chat_bubble)

		if message.is_you():
			chat_bubble.set_style_as_you();

		chat_bubble.set_text(message.text)

	await get_tree().process_frame
	chat_box_scroll.scroll_vertical = chat_box_scroll.get_v_scroll_bar().max_value


	# Some algoirthm to init the chat bubble from top to bottom [0->n]
	# Set scroll view to max value, for bottom











func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() && mouse_in:
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

func _physics_process(delta):
	if dragging:
		var target_position = newPosition

		# Apply screen boundaries if enabled
		if use_screen_boundaries:
			target_position = _clamp_to_screen(target_position)

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

func _clamp_to_screen(target_pos: Vector2) -> Vector2:
	var screen_size = get_viewport_rect().size
	var clamped_pos = target_pos

	clamped_pos.x = clamp(target_pos.x, boundary_margin, screen_size.x - boundary_margin)
	clamped_pos.y = clamp(target_pos.y, boundary_margin, screen_size.y - boundary_margin)

	return clamped_pos

func _mouse_entered() -> void:
	mouse_in = true

func _mouse_exited() -> void:
	mouse_in = false


class RegisteredThread:
	var thread: MessageThreadContent
	var node_thread: MassagerUserThread = null
	var waiting_user: bool = false
	var waiting_thread: MessageThreadContent = null


	func _init(thread: MessageThreadContent, node: MassagerUserThread):
		self.thread = thread
		self.node_thread = node

	# this function must be used for runtime purpose
	# to emitate real chating
	#
	# will halt if message contains "you"
	# and wait for user to procedd
	func runtime_message():
		pass
