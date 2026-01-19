@tool
class_name MessageThreadContent extends Resource

@export var person: String = "Jacob"
@export var thread: Array[MessageChat] = []

var visited: bool = false

func append_thread(thread: MessageThreadContent):
	if self.person != thread.person: return
	self.thread.append_array(thread.thread)

func append_chat(chat: MessageChat):
	thread.append(chat)
