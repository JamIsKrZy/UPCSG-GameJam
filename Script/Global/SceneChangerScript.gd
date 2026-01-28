class_name SceneChanger extends Node

enum GameDay{ DAY_1, DAY_2, DAY_3, None }


@export_category("Game Scenes")
@export var menu: PackedScene = null
@export var day_1: PackedScene = null
@export var day_2: PackedScene = null
@export var day_3: PackedScene = null
@export var intro_scene: PackedScene = null
@export var outro_scene: PackedScene = null



@export_category("Day 1 Data")
@export var _pre_dialogue_: ScriptResource
@export_dir var _bad_ending_dialogue: String = ""
@export var _good_ending: ScriptResource = null

@export_category("Day 2 Data")
@export var __pre_dialogue_: ScriptResource
@export_dir var __bad_ending_dialogue: String = ""
@export var __good_ending: ScriptResource = null

@export_category("Day 3 Data")
@export var ___pre_dialogue_: ScriptResource
@export_dir var ___bad_ending_dialogue: String = ""
@export var ___good_ending: ScriptResource = null

var _in_game: GameDay = GameDay.None
var pre_scene_script: ScriptResource = null
var post_scene_script: ScriptResource = null

func _change_scene(scene: PackedScene):
	screen_black_out()
	AudioSystem._clean_streams()
	get_tree().change_scene_to_packed(scene)



func screen_black_out():
	pass

func screen_fade_in():
	pass

func _shuffle_select_bad_ed_script() -> ScriptResource:
	var results: Array[ScriptResource] = []

	var path: String = "";
	match _in_game:
		GameDay.DAY_1: path = _bad_ending_dialogue
		GameDay.DAY_2: path = __bad_ending_dialogue
		GameDay.DAY_2: path = ___bad_ending_dialogue

	if _bad_ending_dialogue.is_empty():
		push_error("Bad ending dialogue folder path is empty")
		return null

	var dir := DirAccess.open(_bad_ending_dialogue)
	if dir == null:
		push_error("Failed to open directory: %s" % _bad_ending_dialogue)
		return null

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			# Optional: filter only resource files
			if file_name.ends_with(".tres") or file_name.ends_with(".res"):
				var full_path := _bad_ending_dialogue.path_join(file_name)
				var res := load(full_path)

				if res is ScriptResource:
					results.append(res)

		file_name = dir.get_next()
	dir.list_dir_end()

	if results.is_empty():
		push_warning("No ScriptResource found in folder")
		return null

	results.shuffle()
	return results[0]



func done_day(progression_complete: bool):
	assert(_in_game != GameDay.None, "Why you call play, no cue of setting up day")

	if progression_complete:
		post_scene_script = _good_ending
	else:
		post_scene_script = _shuffle_select_bad_ed_script()

	if not post_scene_script: printerr("Day ", _in_game, " does not contain a defined path for script resrouce")
	assert(post_scene_script, "Path Undefined")
	_change_scene(outro_scene)


func play_day():
	assert(_in_game != GameDay.None, "Why you call play, no cue of setting up day")

	var scene_to: PackedScene;
	match _in_game:
		GameDay.DAY_1: scene_to = day_1
		GameDay.DAY_2: scene_to = day_2
		GameDay.DAY_3: scene_to = day_3

	assert(scene_to, "No Scene being supplied. Go To SceneHandler Scene")
	_change_scene(scene_to)


func start_day(day: GameDay):
	_in_game = day

	match day:
		GameDay.DAY_1: pre_scene_script = _pre_dialogue_
		GameDay.DAY_2: pre_scene_script = __pre_dialogue_
		GameDay.DAY_3: pre_scene_script = ___pre_dialogue_

	_change_scene(intro_scene)


func go_to_menu():
	post_scene_script = null
	pre_scene_script = null
	_in_game = GameDay.None

	_change_scene(menu)


# func _ready():
# 	assert(menu)
# 	assert(day_1)
# 	assert(day_2)
# 	assert(day_3)
# 	assert(bad_ending)

# 	assert(DirAccess.dir_exists_absolute(day_1_bad_ending_dialogue))
# 	assert(day_1_good_ending)

# 	assert(DirAccess.dir_exists_absolute(day_2_bad_ending_dialogue))
# 	assert(day_2_good_ending)

# 	assert(DirAccess.dir_exists_absolute(day_3_bad_ending_dialogue))
# 	assert(day_3_good_ending)
