class_name MassagerUserThread extends Panel

var id: int = -1
var handler: Messager = null
var in_thread_gui = false

@export var name_label: Label = null
@export var recent_label: Label = null
@export var img_texture: TextureRect = null

func _ready() -> void:
	assert(name_label)
	assert(recent_label)
	assert(img_texture)

func setup(id: int, name: String, recent_msg: MessageChat, img: Texture2D, handler_ref: Messager) -> void:
	self.id = id
	self.name = name
	handler = handler_ref

	name_label.text = name
	img_texture.texture = img

	if recent_msg.is_image:
		recent_label.text = "Sent an Attachment"
	else:
		var msg = recent_msg.text.replace("\n", " ").replace("\r", " ")
		if recent_msg.is_you(): msg = "You: " + msg
		recent_label.text = msg

	if not recent_msg.is_you(): recent_label.label_settings = recent_label.label_settings.duplicate(true)

func new_recent_message(recent_msg: MessageChat):
	if recent_msg.is_image:
		recent_label.text = "Sent an Attachment"
	else:
		var msg = recent_msg.text.replace("\n", " ").replace("\r", " ")
		if recent_msg.is_you(): msg = "You: " + msg
		recent_label.text = msg

	if not recent_msg.is_you(): recent_label.label_settings.outline_size = 2



func visited():
	recent_label.label_settings.outline_size = 0

func get_texture() -> Texture2D:
	return img_texture.texture



func _highlight_univisted_message():
	assert(false, "TODO")
	pass

func update_recent_msg(msg: String):
	recent_label.text = msg
	_highlight_univisted_message()

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and in_thread_gui:
		self.visited()
		handler.__open_thread(self.id)

func _on_mouse_entered() -> void:
	in_thread_gui = true


func _on_mouse_exited() -> void:
	in_thread_gui = false
