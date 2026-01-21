@tool
class_name MessageThreadContent extends Resource

@export var person: String = "Jacob"
@export var messages: Array[MessageChat] = []

var visited: bool = false



func append_thread(thread: MessageThreadContent):
	if self.person != thread.person: return
	self.messages.append_array(thread.messages)

func append_chat(chat: MessageChat):
	messages.append(chat)

func recent_message() -> MessageChat:
	return messages.get(messages.size() - 1)
