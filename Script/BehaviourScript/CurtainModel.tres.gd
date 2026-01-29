@tool
class_name CurtainModel extends Node3D

@export_range(0.05, 0.8, 0.01) var open_scale: float = 0.3
@export_range(0.,1.,0.01) var meter_ratio: float = 0.
@export var trans: Curve = null

@onready var ring: Node3D = $Group001/Torus026
@onready var blanket: Node3D = $Group001/Plane

var base_blanket_scale: float;
var base_ring_scale: float;

func _ready():
	base_blanket_scale = 61
	base_ring_scale = 1.0

	print(base_blanket_scale)
	print(base_ring_scale)

func _process(delta: float) -> void:
	var curve_res = trans.sample(meter_ratio)
	var scale_b = lerp( base_blanket_scale * open_scale, base_blanket_scale, curve_res)
	blanket.scale.x = scale_b

	var scale_r = lerp( base_ring_scale * open_scale * 0.9, base_ring_scale, curve_res)
	ring.scale.z = scale_r
