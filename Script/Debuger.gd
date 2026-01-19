class_name DebugerStat extends Control

@export_group("Item States")
@export var disable_items: bool = false
@export var door: DoorBehavior = null
@export var window: WindowBehavior = null
@export var tv: TvBehavior = null

@export_group("Entity Handlers")
@export var door_entity: DoorEntityHandler = null
@export var tv_entity: TVEntityHandler = null
@export var window_entity: WindowEntityHandler = null


@export_group("System Managers")
@export var player_state: PlayerStats = null
@export var room_state: RoomStats = null
@export var time_state: TimeElapsed = null



@onready var sanity_value_label: Label = $Container/Sanity/Value
@onready var in_sanity_value_label: Label = $Container/InSanity/Value

@onready var hr_value_label: Label = $Container/HeartRate/Value

@onready var room_value_label: Label = $Container/RoomLight/Value

@onready var time_value_label: Label = $Container/Time/Value






@onready var door_active_label: Label = $RoomStates/Door/Value
@onready var door_locked_label: Label = $RoomStates/DoorLock/Value

@onready var window_active_label: Label = $RoomStates/WindowActive/Value
@onready var window_closed_label: Label = $RoomStates/WindowClosed/Value
@onready var window_progress_label: Label = $RoomStates/WindowProgress/Value
@onready var window_locked_label: Label = $RoomStates/WindowLocked/Value

@onready var tv_active_label: Label = $RoomStates/TVActive/Value
@onready var tv_locked_label: Label = $RoomStates/TVLocked/Value






@onready var door_entity_label: Label = $EntityLoader/DoorEntity/Value
@onready var door_meter_label: Label = $EntityLoader/DoorMeter/Value

@onready var tv_entity_active_label: Label = $EntityLoader/TvActive/Value
@onready var tv_meter_label: Label = $EntityLoader/TvAttackMeter/Value

@onready var window_entity_label: Label = $EntityLoader/WindowEntity/Value
@onready var window_meter_label: Label = $EntityLoader/WindowAttackMeter/Value


func _ready() -> void:
	assert(player_state)
	assert(room_state)
	assert(time_state)

	if disable_items:
		$RoomStates.hide()

func _entity_str(entity: BaseEntity) -> String:
	if entity == null: return "None"

	match entity.type:
		EntityManager.Entity.ENTITY_01: return "Entity01"
		EntityManager.Entity.ENTITY_02: return "Entity02"

	return "Undefined"

func _physics_process(_delta: float) -> void:
	sanity_value_label.text = str(player_state.sanity)
	in_sanity_value_label.text = "on" if player_state.in_sanity else "off"

	hr_value_label.text = str(player_state.heart_rate)

	room_value_label.text = str(room_state.light)

	time_value_label.text = str(time_state.hour) + ":" + str(time_state.minute)


	door_entity_label.text = _entity_str(door_entity.entity_ref)
	door_meter_label.text =  "%.2f" % door_entity.entity_ref.attack_meter if door_entity.entity_ref else "0"

	tv_active_label.text = "Entity404" if tv_entity.entity_ref else "None"
	tv_meter_label.text = "%.2f" % tv_entity.entity_ref.attack_meter if tv_entity.entity_ref else "0"

	window_entity_label.text = _entity_str(window_entity.entity_ref)
	window_meter_label.text = "%.2f" % window_entity.entity_ref.attack_meter if window_entity.entity_ref else "0"



	if !disable_items:
		door_active_label.text = "on" if door.open else "off"
		door_locked_label.text = "locked" if door.locked else "unlocked"

		window_active_label.text = "on" if window.active else "off"
		window_closed_label.text = "on" if window.closed else "off"
		window_progress_label.text = "%.2f" % window.progress_range
		window_locked_label.text = "locked" if window.locked else "unlocked"

		tv_active_label.text = "on" if tv.on else "off"
		tv_locked_label.text = "locked" if tv.locked else "unlocked"
