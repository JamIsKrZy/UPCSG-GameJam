class_name SocMedPost extends Panel


var content: MediaContent
var controller_ref: Object = null

@onready var relation_container: HBoxContainer = $MarginContainer/ContentContainer/Relation
@onready var relation_container_who: Label = $MarginContainer/ContentContainer/Relation/Person
@onready var relation_container_action: Label = $MarginContainer/ContentContainer/Relation/Label
@onready var hor_line_1: Panel = $MarginContainer/ContentContainer/BorderLine

@onready var profile_rect: TextureRect = $MarginContainer/ContentContainer/HBoxContainer/TextureRect
@onready var name_label: Label = $MarginContainer/ContentContainer/HBoxContainer/MarginContainer/Label
@onready var description_label: Label = $MarginContainer/ContentContainer/Description

@onready var image_container: HBoxContainer = $MarginContainer/ContentContainer/AttachedImages
@onready var image_slot_1: TextureRect = $MarginContainer/ContentContainer/AttachedImages/TextureRect
@onready var image_slot_2: TextureRect = $MarginContainer/ContentContainer/AttachedImages/TextureRect2

@onready var like_details: Label = $MarginContainer/ContentContainer/MarginContainer/Label



func setup(content: MediaContent):
	self.content = content
	var height_base: float = 110
	# Relation section of the post
	if content.commented or content.shared:
		relation_container_who.text = content.done_by if content.done_by else "Undefined"
		relation_container_action.text = "commented on this" if content.commented else "shared this post"
		height_base += 20
	else:
		relation_container.queue_free()
		hor_line_1.queue_free()

	profile_rect.texture = RegAccounts.get_account_texture(content.account)

	name_label.text = content.account
	if not content.description.is_empty():
		description_label.text = content.description
		height_base += 20
	else:
		description_label.queue_free()
		height_base -= 50


	var attached_count: int = content.images.size()
	if attached_count != 0:
		if attached_count == 1:
			image_slot_1.texture = content.images[0]
			image_slot_2.queue_free()
		else:
			image_slot_1.texture = content.images[0]
			image_slot_2.texture = content.images[1]

		height_base += 230
	else:
		image_container.queue_free()
		height_base -= 40


	if content.likes != 0:
		if content.a_friend_liked:
			like_details.text = content.friend_liked + " and  " + str(content.likes) + " people liked this post"
		else:
			like_details.text = str(content.likes) + " people liked this post"

		height_base += 20

	else:
		like_details.queue_free()


	var line_count = description_label.get_visible_line_count()
	self.custom_minimum_size = Vector2(0., (line_count * 20)+ height_base)
