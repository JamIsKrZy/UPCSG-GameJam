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

func get_texture() -> Texture2D:
	return img_texture.texture

func update_recent_msg(msg: String):
	recent_label.text = msg

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and in_thread_gui:
		handler.__open_thread(self.id)

func _on_mouse_entered() -> void:
	in_thread_gui = true


func _on_mouse_exited() -> void:
	in_thread_gui = false
