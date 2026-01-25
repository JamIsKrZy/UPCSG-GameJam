@icon("res://common/assets/node_icons/disc.svg")

class_name AudioLoader extends Node

@export var prep_load: Array[AudioResource] = []

func _ready() -> void:
	for res in prep_load:

		var player_ref = AudioSystem.add_stream(res)
		if player_ref == null:
			print("[WARNING][AudioLoader] Failed to load in Audio Manager, either due to its already existing")
		else:
			print("[DEBUG] ", res.name ," is now registered in Audio Manager")
