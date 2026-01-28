@tool
class_name DoorEntity01 extends PathFollow3D

@export var y_range: float = 0.1
@export var speed: float = 0.5
@export var fade_speed: float = 1.
@export var max_energy: float = 5.


@onready var sprite_node: AnimatedSprite3D = $Sprite
@onready var light: OmniLight3D = $Light

var time_passed := 0.0
var start_y := 0.0
var follow_path: bool = true

func _ready():
	start_y = 0.

func _process_light():
	var fade := (sin(time_passed * fade_speed * TAU) + 1.0) * 0.5

	# Path influence (0 → 1)
	var path_strength : float = clamp(progress_ratio, 0.0, 1.0)

		# Final light energy
	light.light_energy = max_energy * fade * path_strength

func _process_sprite():
	var res := sin(time_passed * speed)
	sprite_node.position.y = start_y + res * y_range

func _process_postion():
	if not follow_path: return


func _process(delta: float) -> void:
	time_passed += delta

	_process_sprite();
	_process_light();
