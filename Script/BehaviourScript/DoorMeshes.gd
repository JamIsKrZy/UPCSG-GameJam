@tool
class_name DoorModel extends Node3D

@export var open: bool:
	set(val):
		open = val

@export var speed: float = 1.5
@export var open_curve: Curve = null
@export var close_curve: Curve = null

@onready var door: Node3D = $"D1-Door"

const open_angle: float = 102.;
const close_angle: float = 0.;

var ratio: float = 0.

func _ready() -> void:
	open_door()

func open_door():
	open = true
	# door.rotation.z = deg_to_rad(102.)

func close_door():
	open = false
	# door.rotation.z = deg_to_rad(0.)


func _process(delta: float) -> void:
	var angle_res;
	if open:
		ratio += delta * speed;
		ratio = min(1., ratio)
		var res =  open_curve.sample(ratio);
		res = lerp(close_angle, open_angle, res);
		angle_res = res
	else:
		ratio -= delta * speed;
		ratio = max(0., ratio)
		var res =  1.- close_curve.sample(ratio);
		res =  lerp(open_angle, close_angle, res);
		angle_res = res

	angle_res = deg_to_rad(angle_res);
	door.rotation.z = angle_res
