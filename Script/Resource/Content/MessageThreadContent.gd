@tool
class_name MessageThreadContent extends Resource

@export var overwrite_queue: bool = false
@export var person: String = "Jacob"
@export var messages: Array[MessageChat] = []

func pop_waiting_messages() -> MessageThreadContent:
	var waiting_msg: Array[MessageChat] = []
	var process_msg = messages
	messages = []

	var go_to_queue: bool = false
	for message in process_msg:
		if go_to_queue:
			waiting_msg.push_back(message)
			continue

		if message.is_you() and message.required_manual_reply:
			go_to_queue = true
			waiting_msg.push_back(message)
			continue

		messages.push_back(message)

	var obj = MessageThreadContent.new()
	obj.overwrite_queue = false
	obj.person = self.person
	obj.messages = waiting_msg
	return obj


func append_thread(thread: MessageThreadContent):
	if self.person != thread.person: return
	self.messages.append_array(thread.messages)

func append_chat(chat: MessageChat):
	messages.append(chat)

func recent_message() -> MessageChat:
	return messages.get(messages.size() - 1)
