@tool
class_name Entity1Nodey extends Node3D

@export var parent: PathFollow3D = null

@export var y_range: float = 0.1
@export var scale_range: float = 0.5
@export var speed: float = 0.5
@export var fade_speed: float = 1.
@export var max_energy: float = 5.

@onready var group: Node3D = $Entity
@onready var sprite_node: AnimatedSprite3D = $Sprite
@onready var light: OmniLight3D = $Light

var time_passed := 0.0
var start_y := 0.0
var start_scale := Vector3(1.9, 1.9, 1.9)
var follow_path: bool = true

func _ready():
	assert(parent)
	start_y = 0.
	start_scale = sprite_node.scale

	sprite_node.play()

func _process_light():
	var fade := (sin(time_passed * fade_speed * TAU) + 1.0) * 0.5

	# Path influence (0 → 1)
	var path_strength : float = clamp(parent.progress_ratio, 0.0, 1.0)

		# Final light energy
	light.light_energy = max_energy * fade * path_strength

func _process_sprite():
	var res : float = (sin(time_passed * speed) + 1.0) * 0.5
	var scale_value : float = lerp(1.5, 2.2, res)

	sprite_node.position.y = start_y + sin(time_passed * speed) * y_range
	sprite_node.scale = Vector3.ONE * scale_value

func _process_postion():
	if not follow_path: return

func get_entity_node():
	return group

func _process(delta: float) -> void:
	time_passed += delta

	_process_sprite();
	_process_light();
