class_name Messager extends CharacterBody2D

const new_message_interval: float = 1.5

var draggingDistance
var dir
var dragging
var newPosition = Vector2()


var mouse_in = false


@export var use_screen_boundaries = true
@export var boundary_margin = 3  # Pixels from screen edge
@export var use_collision_check = true  # Check for StaticBody2D collisions

# texting purposes
@export var ready_threads: Array[MessageThreadContent] = []

@export_group("Link Nodes")
@export var chat_box_texture: TextureRect = null
@export var chat_box_label: Label = null

@onready var reply_button: Button = $Control/ChatBox/Reply
@onready var account_slots: VBoxContainer = $Control/Panel/ScrollContainer/AccountSlot
@onready var chat_box: VBoxContainer = $Control/ChatBox/ChatContainer/ScrollContainer/MarginContainer/BubbleContainer
@onready var chat_box_scroll: ScrollContainer = $Control/ChatBox/ChatContainer/ScrollContainer
var MessengerScene := preload("res://MainScene/Laptop/MessagerUserThread.tscn")
var ChatBubbleScene := preload("res://MainScene/Laptop/MessageChatBubble.tscn")


var registered_threads: Dictionary[int,RegisteredThread] = {};
var person_id: Dictionary[String, int] = {};

var active_thread: RegisteredThread = null


var tree_node: Node = null

func _ready():
	assert(account_slots)
	assert(chat_box)

	reply_button.visible = false
	reply_button.disabled = true
	reply_button.pressed.connect(_reply_action_pressed)

	_empty_chat_box()

	if OS.is_debug_build():
		_init_message_threads()
	else:
		ready_threads = []

func supply_tree_node(node: Node):
	tree_node = node

var id_counter = 0
func _init_message_threads():
	for thread in ready_threads:
		if thread == null: continue

		if _check_person_is_registered(thread):
			# Some appending stufff to do

			var reg_thread = _get_thread(thread);
			reg_thread.merge(thread)

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
		account_slots.move_child(slot,0)
		_register_thread(id_counter, thread, slot)
		id_counter += 1;

func _check_person_is_registered(thread: MessageThreadContent) -> bool:
	return person_id.has(thread.person)

func _register_thread(id: int, thread: MessageThreadContent, node: MassagerUserThread):
	person_id[thread.person] = id
	var thread_ref = RegisteredThread.new(thread, node)
	registered_threads[id] = thread_ref

# This function is recommended to use when starting of the game
func ready_messages(threads: Array[MessageThreadContent]):
	ready_threads = threads
	_init_message_threads()




# Creates a new thread and node
func _new_register_thread(thread: MessageThreadContent):
	var slot: MassagerUserThread = MessengerScene.instantiate();
	slot.setup(
		id_counter,
		thread.person,
		thread.recent_message(),
		RegAccounts.get_account_texture(thread.person),
		self
	)

	account_slots.add_child(slot)
	account_slots.move_child(slot,0)
	_register_thread(id_counter, thread, slot)
	id_counter += 1

func _append_chat_clock(reg_thread: RegisteredThread):
	var is_processed = reg_thread.process_one_message();
	if not is_processed:
		if reg_thread == self.active_thread and reg_thread.need_action_reply:
			reply_button.disabled = false
			reply_button.visible = true
		return

	if reg_thread == self.active_thread:
		__open_thread(reg_thread.node_thread.id)
		reg_thread.node_thread.visited()


	self.account_slots.move_child(reg_thread.node_thread, 0);

	var timer = tree_node.get_tree().create_timer(new_message_interval, true, true)
	timer.timeout.connect(Callable(self, "_append_chat_clock").bind(reg_thread))



func new_message(thread: MessageThreadContent):
	# Insert it to the messages data structure
	# If its being viewed in screen then insert new chat bubble
	var registered_thread = _get_thread(thread);
	if registered_thread == null:
		print("[ Messager ] Not Registered - creating new thread")
		_new_register_thread(thread)
		return


	registered_thread.new_message(thread);
	_append_chat_clock(registered_thread)


func _reply_action_pressed():
	if self.active_thread == null: return

	reply_button.disabled = true
	reply_button.visible = false

	active_thread.reply()
	_append_chat_clock(active_thread)



func _get_thread(thread: MessageThreadContent) -> RegisteredThread:
	var id: int = person_id.get(thread.person,-1);
	if id == -1: return null;
	return registered_threads.get(id, null)








# OPens the thread to the chat box
func __open_thread(id: int):
	print("[ MessagerHandler ] Opened/Refreshed for ", registered_threads[id].thread.person)

	reply_button.disabled = true
	reply_button.visible = false

	var thread_data: RegisteredThread = registered_threads.get(id, null)
	if thread_data == null:
		printerr("[ MessagerHandler ] Open Thread: No id:", id, " is assigned!")
		return
	_swap_chat_box(thread_data)

	if thread_data.need_action_reply:
		reply_button.disabled = false
		reply_button.visible = true

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



	signal update_message()

	var thread: MessageThreadContent
	var node_thread: MassagerUserThread = null
	var need_action_reply: bool = false

	# waiting for user input to process the following messages
	var queue_message: MessageThreadContent = null

	var is_processing: bool = false

	#  this is message to be proces by time, means will be displayed
	var to_process_message: MessageThreadContent

	func _init(thread: MessageThreadContent, node: MassagerUserThread):
		self.thread = thread
		self.node_thread = node

		queue_message = thread.pop_waiting_messages()
		if queue_message && not queue_message.is_empty():
			self.need_action_reply = true

		node_thread.new_recent_message(thread.recent_message())

	# do not imatate real time chatting
	func merge(thread: MessageThreadContent):
		if self.thread.person != thread.person: return
		self.thread.append_thread(thread)
		self.node_thread.new_recent_message(self.thread.recent_message())


	# return false if no more message to process
	func process_one_message() -> bool:
		if to_process_message == null || to_process_message.messages.size() == 0:

			if queue_message != null && queue_message.messages.size() != 0:
				need_action_reply = true

			to_process_message = null
			return false


		var message: MessageChat = to_process_message.pop_message();
		thread.append_chat(message)
		node_thread.new_recent_message(message)
		return true




	# this only sorted the data not process
	func new_message(append: MessageThreadContent):
		need_action_reply = false


		var need_reply: MessageThreadContent = append.pop_waiting_messages()
		if need_reply.is_empty():
			queue_message = null
		else:
			queue_message = need_reply
			need_action_reply = true

		# print(need_reply.messages.size())
		# print(append.messages.size())

		if to_process_message == null:
			to_process_message = MessageThreadContent.new()
			to_process_message.person = thread.person
		to_process_message.append_thread(append)


	func reply():
		if queue_message == null:
			printerr("[ MessageSystem ] Calling reply to ")
			return

		var process_message = queue_message
		need_action_reply = false

		var need_reply = process_message.reply_then_pop_waiting_messages()
		if need_reply.is_empty():
			queue_message = null
		else:
			queue_message = need_reply


		if to_process_message == null:
			to_process_message = MessageThreadContent.new()
			to_process_message.person = thread.person
		to_process_message.append_thread(process_message)
