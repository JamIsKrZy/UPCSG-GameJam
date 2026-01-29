class_name RegisteredAccounts extends Node

@export var default_texture: Texture2D = null
@export var accounts: Dictionary[String, Texture2D] = {}

func _ready() -> void:
	assert(default_texture)

func get_account_texture(name: String) -> Texture:
	return accounts.get(name, default_texture)
