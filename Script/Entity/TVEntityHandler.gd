class_name TVEntityHandler extends Node


@export var interval: Vector2 = Vector2(15.,20.)
@export var reactivate_interval: Vector2 = Vector2(15.,20.)
@export var disable: bool = false

@export_group("Entity Weight")
@export_range(0.01,1.0,0.01) var __entity_404: float = 0.3
@export_range(0.01,1.0,0.01) var __none: float = 0.8


@export_group("Dependent")
@export var _tv_state: TvBehavior = null

@export_group("System")
@export var entity_manager: EntityManager = null

# Entity that exist
var entity_ref: ApproachingEntity = null

var total_weight: float
var next_state_timer: SceneTreeTimer = null

func _ready():
	assert(_tv_state)
	assert(entity_manager)

	var entities = _get_weighted_entities();
	for e in entities:
		total_weight += e.weight

	if !disable:
		_create_new_interval_timer()
		_tv_state.tv_toggled.connect(_tv_toggled_state)



func _get_weighted_entities() -> Array:
	return [
		{ "id": EntityManager.Entity.ENTITY_404, "weight": __entity_404},
		{ "id": -1, "weight": __none }
	]

func _roll_entity() -> int:
	var entities = _get_weighted_entities()

	var roll := randf() * total_weight
	var running := 0.0

	for e in entities:
		running += e.weight
		if roll <= running:
			return e.id

	return -1 # should never happen


func _roll_spawn():
	var entity = _roll_entity()
	match entity:
		EntityManager.Entity.ENTITY_404:
			print("[ TVEntityHandler ] Entity404 Spawned")

			var ra: Vector2 = entity_manager._404_charge_interval;
			var charge_duration = randf_range(ra.x, ra.y)

			entity_ref = ApproachingEntity.new(
				EntityManager.Entity.ENTITY_01,
				entity_manager._404_leave_interval,
				charge_duration,
				_tv_state.on
			)
			entity_ref.entity_left.connect(_entity_left)
			entity_ref.entity_attack.connect(_entity_attacked)
			self.set_physics_process(true)

		_:
			print("[ TVEntityHandler ] No Spawned - Idle")
			_create_new_interval_timer()

func _entity_attacked():
	# Dummy
	assert(false, "You Lose")
	pass

func _tv_toggled_state(is_on: bool):
	print("Toggled", is_on)
	if !entity_ref: return
	if entity_ref is ApproachingEntity:
		if is_on:
			entity_ref.door_open()
		else:
			entity_ref.door_shut()

func _entity_left():
	print("[ TVEntityHandler ] Entity has left")
	entity_ref = null

	self.set_physics_process(false)
	var wait_duration = randf_range(self.reactivate_interval.x, self.reactivate_interval.y)

	var timer = get_tree().create_timer(wait_duration, true, true)
	timer.timeout.connect(_roll_spawn)
	next_state_timer = timer





func _create_new_interval_timer():
	self.set_physics_process(false)
	var wait_duration = randf_range(self.interval.x, self.interval.y)

	var timer = get_tree().create_timer(wait_duration, true, true)
	timer.timeout.connect(_roll_spawn)
	next_state_timer = timer




func _physics_process(delta: float) -> void:

	if entity_ref:
		entity_ref.process(delta)

		# update 3d model position
		if !entity_ref: return
		var t = entity_ref.type
		if t == EntityManager.Entity.ENTITY_01:
			pass
		elif t == EntityManager.Entity.ENTITY_02:
			pass
