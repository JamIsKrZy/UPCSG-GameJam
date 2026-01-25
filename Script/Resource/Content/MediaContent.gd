@tool
class_name MediaContent extends Resource

@export var account: String = "Anonymous 404"
@export_multiline var description: String = "[Empty Post]"
@export var likes: int = 0

@export var a_friend_liked: bool = false
@export var friend_liked: String = "Anon Friend"

@export var images: Array[Texture2D] = []

# either liked or shared, player will be hijacked
@export var hacked: bool = false


@export var commented: bool = false:
	set(val):
		if shared: shared = false
		commented = val

@export var shared: bool = false:
	set(val):
		if commented: commented = false
		shared = val

@export var done_by: String = "Anon"

var id = -1
