class_name HoldRectProto extends BaseBehavior

@export var mesh: MeshInstance3D
@export var color: Color

@onready var _given_color: Color = (mesh.mesh.surface_get_material(0) as StandardMaterial3D).albedo_color;

var progress_state: float = 0.;
var _pressed: bool = false


func call_trigger():
	_pressed = !_pressed
	if _pressed:
		self.set_process(true)

# some kind of graphic indicator
func hovered_reference():
	pass

func enable_trigger():
	pass

func disable_trigger():
	pass


func _process(delta: float) -> void:
	var m: StandardMaterial3D = mesh.mesh.surface_get_material(0);
	m.albedo_color = lerp(_given_color, color, progress_state)

	if _pressed:
		progress_state = min(1., progress_state + delta)
	else:
		progress_state = max(0., progress_state - delta)
		if progress_state <= 0.:
			self.set_process(false)

	m.albedo_color = lerp(_given_color, color, progress_state)
