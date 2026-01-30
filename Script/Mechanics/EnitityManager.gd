class_name  EntityManager extends Node

enum Entity{
	ENTITY_01,
	ENTITY_02,
	ENTITY_03,
	ENTITY_101,
	ENTITY_404,
}

@export_group("Spawning ")
@export_range(1,3) var entity_01: int = 1
@export_range(1,3) var entity_02: int = 1



@export_group("System")
@export var player_system: PlayerStats = null
@export var laptop_hover_slot: LaptopSlot = null

@export_category("Entity Behavior")
@export_group("Entity01")
@export var _01_charge_interval: Vector2 = Vector2(5.0,10.);
@export var _01_leave_interval: float = 3.0
@export var _01_attack_position: Node3D
@export var _01_attack_tick_interval: float = 0.3

@export_group("Entity02")
@export var _02_charge_interval: Vector2 = Vector2(5.0,10.);
@export var _02_leave_interval: float = 3.0


@export_group("Entity03")
@export var _03_stare_interval: float = 2.0
@export var _03_leave_interval: float = 5.0

@export_group("Entity404")
@export var _404_charge_interval: Vector2 = Vector2(5.0,10.);
@export var _404_leave_interval: float = 2.0
@export var _lock_interval: float = 2.0






# func _entity_atttacked(entity: Entity):
# 	match entity:
# 		Entity.ENTITY_01:
# 			_entity_01_trigger()
# 		Entity.ENTITY_02:
# 			_entity_02_trigger()
# 		Entity.ENTITY_03:
# 			_entity_03_trigger()
# 		Entity.ENTITY_404:
# 			_entity_404_trigger()
# 		Entity.ENTITY_101:
# 			_entity_101_trigger()

func _entity_404_left():
	laptop_hover_slot.unlock_slot();

func _entity_404_attack():
	laptop_hover_slot.lock_slot();



func _entity_01_attack_loop():
	var timer = get_tree().create_timer(_01_attack_tick_interval)
	timer.timeout.connect(_entity_01_attack_loop)
	await timer.timeout
	player_system.tick_heart_rate()

func entity_01_attack(from_path: DoorEntity01):
	from_path.set_process(false)
	var entity_node = from_path.get_entity_node();
	entity_node.top_level = true;
	entity_node.global_transform = entity_node.global_transform

	get_tree().create_tween().tween_property(
		entity_node,
		"global_position",
		_01_attack_position.global_position,
		3.
	)
	_entity_01_attack_loop()


	# TODO: set infinite loop sanity tick

func entity_02_attack():
	player_system.tick_sanity();

func _entity_free():
	pass

func _ready():
	assert(laptop_hover_slot)
	assert(player_system)
	assert(_01_attack_position)
