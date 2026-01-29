class_name DoorEntityHandler extends Node

# rest time before spawning again
@export var spawn_cooldown: Vector2 = Vector2(6.,13.)

@export var interval: Vector2 = Vector2(5.0, 10.0)

@export var disable: bool = false

@export_group("Entity Weight")
@export_range(0.01,1.0,0.01) var __entity_01: float = 0.5
@export_range(0.01,1.0,0.01) var __entity_02: float = 0.5
@export_range(0.01,1.0,0.01) var __none: float = 0.5

@export_group("Entity Display Movement")
@export var _01_target_position: Vector3

@export_group("Dependent")
@export var _door_state: DoorBehavior = null
@export var entity_01: DoorEntity01 = null
@export var entity_02: Entity02Path = null

@export_group("System")
@export var entity_manager: EntityManager = null

var total_weight: float = 0
var time_tick_callable: SceneTreeTimer = null
var occupied: bool = false

var entity_ref: BaseEntity = null



func _ready() -> void:
	assert(interval.x < interval.y, "x value has to be lesser than y")

	assert(entity_manager)
	assert(_door_state)
	assert(entity_01)
	assert(entity_02)

	self.set_physics_process(false)

	entity_01.progress_ratio = 0.
	entity_02.progress_ratio = 0.
	var entities = _get_weighted_entities()
	for e in entities:
		total_weight += e.weight

	if !disable:
		_renew_interval_state()
		_door_state.door_toggled.connect(_door_toggle)

func _get_weighted_entities() -> Array:
	return [
		{ "id": EntityManager.Entity.ENTITY_01, "weight": __entity_01 },
		{ "id": EntityManager.Entity.ENTITY_02, "weight": __entity_02 },
		{ "id": -1, "weight": __none }
	]



func _roll_entity_spawn() -> int:
	var entities = _get_weighted_entities()

	var roll := randf() * total_weight
	var running := 0.0

	for e in entities:
		running += e.weight
		if roll <= running:
			return e.id

	return -1 # should never happen




func _roll_spawn():
	var entity_spawned = _roll_entity_spawn();
	match entity_spawned:
		EntityManager.Entity.ENTITY_01:
			print("[ DoorEntityHandler ] Entity01 Spawned")


			var ra: Vector2 = entity_manager._01_charge_interval;
			var charge_duration = randf_range(ra.x, ra.y)

			entity_ref = ApproachingEntity.new(
				EntityManager.Entity.ENTITY_01,
				entity_manager._01_leave_interval,
				charge_duration,
				_door_state.open
			)
			entity_ref.entity_left.connect(_enemy_just_left)
			entity_ref.entity_attack.connect(_dummy_01_attack)
			self.set_physics_process(true)
		EntityManager.Entity.ENTITY_02:
			print("[ DoorEntityHandler ] Entity02 Spawned")

			var ra: Vector2 = entity_manager._02_charge_interval;
			var charge_duration = randf_range(ra.x, ra.y)

			entity_ref = ApproachingEntity.new(
				EntityManager.Entity.ENTITY_02,
				entity_manager._02_leave_interval,
				charge_duration,
				_door_state.open
			)
			entity_ref.entity_left.connect(_enemy_just_left)
			entity_ref.entity_attack.connect(_dummy_01_attack)
			self.set_physics_process(true)

		_:
			print("[ DoorEntityHandler ] No Spawned - Idle")
			_renew_interval_state()


func _door_toggle(is_open: bool):
	if !entity_ref: return
	if entity_ref is ApproachingEntity:
		if is_open:
			entity_ref.door_open()
		else:
			entity_ref.door_shut()

func _dummy_01_attack():
	self.set_physics_process(false)
	print("01 is attacks you lose")
	entity_ref = null
	assert(false)

func _renew_interval_state():
	self.set_physics_process(false)
	var wait_duration = randf_range(self.interval.x, self.interval.y)

	var timer = get_tree().create_timer(wait_duration, true, true)
	timer.timeout.connect(_roll_spawn)
	time_tick_callable = timer

func _enemy_just_left():
	print("[ DoorEntityHandler ] Entity has left")

	var t = entity_ref.type
	if t == EntityManager.Entity.ENTITY_01:
		entity_01.progress_ratio = 0.
	elif t == EntityManager.Entity.ENTITY_02:
		entity_02.fade_out()


	entity_ref = null

	self.set_physics_process(false)
	var wait_duration = randf_range(self.spawn_cooldown.x, self.spawn_cooldown.y)

	var timer = get_tree().create_timer(wait_duration, true, true)
	timer.timeout.connect(_roll_spawn)
	time_tick_callable = timer



func _render_entity_01():
	pass

func _process(delta: float) -> void:
	# update 3d model position
	if !entity_ref: return
	var t = entity_ref.type
	if t == EntityManager.Entity.ENTITY_01:
		entity_01.progress_ratio = entity_ref.attack_meter
	elif t == EntityManager.Entity.ENTITY_02:
		entity_02.play_audio()
		entity_02.progress_ratio = entity_ref.attack_meter
	else:
		entity_01.progress_ratio = 0.
		entity_02.progress_ratio = 0.

func _physics_process(delta: float) -> void:
	if entity_ref:
		entity_ref.process(delta)
