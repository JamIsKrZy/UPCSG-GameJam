class_name WindowEntityHandler extends Node

# rest time before spawning again
@export var spawn_cooldown: Vector2 = Vector2(5.,10.)

@export var interval: Vector2 = Vector2(5.0, 10.0)


@export var disable: bool = false

@export_group("Entity Weight")
@export_range(0.01,1.0,0.01) var __entity_01: float = 0.5
@export_range(0.01,1.0,0.01) var __entity_02: float = 0.5
@export_range(0.01,1.0,0.01) var __none: float = 0.5

@export_group("Entity Display Movement")
@export var _01_target_position: Vector3

@export_group("Dependent")
@export var _window_state: WindowBehavior = null
@export var _entity_01: DoorEntity01 = null
@export var _entity_02: Entity02Path = null

@export_group("System")
@export var entity_manager: EntityManager = null

var total_weight: float = 0
var next_state_timer: SceneTreeTimer = null

var entity_ref: BaseEntity = null

func _ready() -> void:
	assert(interval.x < interval.y, "x value has to be lesser than y")

	assert(entity_manager)
	assert(_window_state)
	assert(_entity_01)
	assert(_entity_02)

	self.set_physics_process(false)


	_entity_01.progress_ratio = 0.
	_entity_02.progress_ratio = 0.
	var entities = _get_weighted_entities()
	for e in entities:
		total_weight += e.weight

	if !disable:
		_create_new_interval_timer()
		_window_state.window_state_changed.connect(_windows_closed)

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
			print("[ WindowEntityHandler ] Entity01 Spawned")


			var ra: Vector2 = entity_manager._01_charge_interval;
			var charge_duration = randf_range(ra.x, ra.y)

			entity_ref = ApproachingEntity.new(
				EntityManager.Entity.ENTITY_01,
				entity_manager._01_leave_interval,
				charge_duration,
				true
			)
			entity_ref.entity_left.connect(_entity_left)
			entity_ref.entity_attack.connect(_dummy_01_attack)
			self.set_physics_process(true)
		EntityManager.Entity.ENTITY_02:
			print("[ WindowEntityHandler ] Entity02 Spawned")

			var ra: Vector2 = entity_manager._02_charge_interval;
			var charge_duration = randf_range(ra.x, ra.y)

			entity_ref = ApproachingEntity.new(
				EntityManager.Entity.ENTITY_02,
				entity_manager._02_leave_interval,
				charge_duration,
				true
			)
			entity_ref.entity_left.connect(_entity_left)
			entity_ref.entity_attack.connect(_dummy_01_attack)
			self.set_physics_process(true)

		_:
			print("[ WindowEntityHandler ] No Spawned - Idle")
			_create_new_interval_timer()


func _windows_closed(is_close: bool):
	if !entity_ref: return
	if entity_ref is ApproachingEntity:
		if is_close:
			entity_ref.door_shut()
		else:
			entity_ref.door_open()

func _dummy_01_attack():
	self.set_physics_process(false)
	print("01 is attacks you lose")
	assert(false, "Your lose")
	entity_ref = null

func _create_new_interval_timer():
	self.set_physics_process(false)
	var wait_duration = randf_range(self.interval.x, self.interval.y)

	var timer = get_tree().create_timer(wait_duration, true, true)
	timer.timeout.connect(_roll_spawn)
	next_state_timer = timer

func _entity_left():
	print("[ WindowEntityHandler ] Entity has left")

	var t = entity_ref.type
	if t == EntityManager.Entity.ENTITY_01:
		_entity_01.progress_ratio = 0.
	elif t == EntityManager.Entity.ENTITY_02:
		_entity_02.fade_out()
	entity_ref = null

	self.set_physics_process(false)
	var wait_duration = randf_range(self.spawn_cooldown.x, self.spawn_cooldown.y)

	var timer = get_tree().create_timer(wait_duration, true, true)
	timer.timeout.connect(_roll_spawn)
	next_state_timer = timer


func _process(delta: float) -> void:
	# update 3d model position
	if !entity_ref: return
	var t = entity_ref.type
	if t == EntityManager.Entity.ENTITY_01:
		_entity_01.progress_ratio = entity_ref.attack_meter
	elif t == EntityManager.Entity.ENTITY_02:
		_entity_02.play_audio()
		_entity_02.progress_ratio = entity_ref.attack_meter
	else:
		_entity_01.progress_ratio = 0.
		_entity_02.progress_ratio = 0.

func _physics_process(delta: float) -> void:
	if entity_ref:
		entity_ref.process(delta)
