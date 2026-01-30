class_name MainLaptop extends TextureRect

signal entity_404()
@export var type_per_ms: float = 0.2

@export var progression_list: Array[int] = []

@export var media_limit: int = -1;

@export_group("Progression")
@export var story_progression: Array[BaseProgression] = []

@export_category("Contents")
@export var media_contents: Array[MediaContent] = []
@export var message_content: Array[MessageThreadContent] = []
@export var diary_content: DiaryContent = null

@export_group("Connector")
@export var messager: Messager = null
@export var diaary: Diaary = null
@export var sociamedya: SociaMedya = null
@export var tree_node: Node = null
@export var disable_assertion: bool = false


func _ready() -> void:
	assert(messager)
	if not disable_assertion: assert(tree_node)
	assert(diaary)
	assert(sociamedya)

	diaary.type_per_ms = type_per_ms

	messager.supply_tree_node(tree_node)

	messager.ready_messages(message_content)

	diaary.append_content(diary_content)

	sociamedya.set_content_limit(media_limit);
	sociamedya.ready_contents(media_contents)
	sociamedya.refresh_page()


func new_message(message: MessageThreadContent):
	messager.new_message(message)

func _progression_finished():
	var _trash_progression = story_progression.pop_front();

# func set_
