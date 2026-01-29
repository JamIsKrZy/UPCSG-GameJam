class_name LaptopSlot extends Control

@export var lock_timer: float = 5.;

@onready var texture_node: TextureRect = $TextureRect

enum SlotState {LOCKED, IDLE, ACTIVE}

signal locked_slot;
signal interact_slot(is_active: bool); 

var state: SlotState = SlotState.IDLE

func unhide_and_unlock():
	state = SlotState.IDLE
	texture_node.visible = true
	
	
func hide_and_lock():
	state = SlotState.LOCKED
	texture_node.hide()
	
func is_active() -> bool:
	return state == SlotState.ACTIVE

func lock_slot():
	locked_slot.emit()
	state = SlotState.LOCKED

func _on_mouse_entered() -> void:
	if state == SlotState.LOCKED: return
	
	state = SlotState.ACTIVE if state == SlotState.IDLE else SlotState.IDLE
	var is_active = state == SlotState.ACTIVE
	interact_slot.emit(is_active)
		
	
