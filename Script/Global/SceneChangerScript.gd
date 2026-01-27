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
	return null

func done_day(is_task_done: bool):
	assert(_in_game != GameDay.None, "Why you call play, no cue of setting up day")

	# if is_task_done:
	# 	post_scene_script =



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
	print("Huh")
	_in_game = day

	match day:
		GameDay.DAY_1: pre_scene_script = _pre_dialogue_
		GameDay.DAY_2: pre_scene_script = __pre_dialogue_
		GameDay.DAY_3: pre_scene_script = ___pre_dialogue_

	_change_scene(intro_scene)


func go_to_menu():
	_in_game = GameDay.None


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
