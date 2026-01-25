class_name SceneChanger extends Node

enum GameDay{ DAY_1, DAY_2, DAY_3 }


@export_category("Game Scenes")
@export var menu: PackedScene = null
@export var day_1: PackedScene = null
@export var day_2: PackedScene = null
@export var day_3: PackedScene = null
@export var bad_ending: PackedScene = null



@export_category("Day 1 Data")
@export_dir var day_1_bad_ending_dialogue: String = ""
@export var day_1_good_ending: PackedScene = null

@export_category("Day 2 Data")
@export var before_2_dialogue: ScriptResource
@export_dir var day_2_bad_ending_dialogue: String = ""
@export var day_2_good_ending: PackedScene = null

@export_category("Day 3 Data")
@export_dir var day_3_bad_ending_dialogue: String = ""
@export var day_3_good_ending: PackedScene = null

var _in_game: bool = false
var _dialogue_before_day_data: ScriptResource = null

var _dialogue_ending_data: ScriptResource = null


# func _select

func play_day(day: GameDay):
	_in_game = true



	match day:
		GameDay.DAY_1: pass
		GameDay.DAY_2: pass
		GameDay.DAY_3: pass


func _go_to_menu():
	_in_game = false


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
