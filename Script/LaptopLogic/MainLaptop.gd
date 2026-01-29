class_name MainLaptop extends TextureRect

signal entity_404()
@export var progression_list: Array[int] = []

@export var media_limit: int = -1;

@export_category("Contents")
@export var media_contents: Array[MediaContent] = []
@export var message_content: Array[MessageThreadContent] = []
@export var diary_content: DiaryContent = null

@export_group("Connector")
@export var messager: Messager = null
@export var diaary: Diaary = null
@export var sociamedya: SociaMedya = null

func _ready() -> void:
	assert(messager)
	assert(diaary)
	assert(sociamedya)

	messager.ready_messages(message_content)

	diaary.append_content(diary_content)

	sociamedya.set_content_limit(media_limit);
	sociamedya.ready_contents(media_contents)
	sociamedya.refresh_page()
