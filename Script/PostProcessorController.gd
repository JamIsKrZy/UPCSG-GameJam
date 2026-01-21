@tool
class_name PostProcessingController extends Control


@onready var radial_blur_node: ColorRect = $RadialBlur
@onready var vignette_node: ColorRect = $Vignette

var _radial_blur_mat: ShaderMaterial = null
var _vignette_mat: ShaderMaterial = null

func _get_radial_mat() -> ShaderMaterial:
	if _radial_blur_mat == null and radial_blur_node:
		_radial_blur_mat = radial_blur_node.material as ShaderMaterial
	return _radial_blur_mat

func _get_vignette_mat() -> ShaderMaterial:
	if _vignette_mat == null and vignette_node:
		_vignette_mat = vignette_node.material as ShaderMaterial
	return _vignette_mat

@export_tool_button("Refresh Parameters") var refresh_parameters: Callable = func():
	var mat = _get_radial_mat()
	_intensity = mat.get_shader_parameter("intensity")
	_falloff = mat.get_shader_parameter("falloff")
	_samples = mat.get_shader_parameter("samples")
	_center = mat.get_shader_parameter("center")

	mat = _get_vignette_mat()
	_inner_radius = mat.get_shader_parameter("inner_radius")
	_outer_radius = mat.get_shader_parameter("outer_radius")
	_vignette_strength = mat.get_shader_parameter("vignette_strength")
	_dither_strength = mat.get_shader_parameter("dither_strength")
	_vignette_color = mat.get_shader_parameter("vignette_color")

func _ready():
	if Engine.is_editor_hint(): return

	var mat = _get_radial_mat()
	mat.set_shader_parameter("intensity", _intensity)
	mat.set_shader_parameter("falloff", _falloff)
	mat.set_shader_parameter("samples", _samples)
	mat.set_shader_parameter("center", _center)

	mat = _get_vignette_mat()
	mat.set_shader_parameter("inner_radius", _inner_radius)
	mat.set_shader_parameter("outer_radius", _outer_radius)
	mat.set_shader_parameter("vignette_strength", _vignette_strength)
	mat.set_shader_parameter("dither_strength", _dither_strength)
	mat.set_shader_parameter("vignette_color", _vignette_color)



@export_category("Radial Blur Parameters")
@export var _intensity: float = 1.5:
	set(val):
		_intensity = val
		var mat = _get_radial_mat()
		if mat:
			mat.set_shader_parameter("intensity", val)

@export var _falloff: float = 0.5:
	set(val):
		_falloff = val
		var mat = _get_radial_mat()
		if mat:
			mat.set_shader_parameter("falloff", val)


@export var _samples: int = 10:
	set(val):
		_samples = val
		var mat = _get_radial_mat()
		if mat:
			mat.set_shader_parameter("samples", val)

@export var _center: Vector2 = Vector2(0.5, 0.5):
	set(val):
		_center = val
		var mat = _get_radial_mat()
		if mat:
			mat.set_shader_parameter("center", val)

@export_category("Vignette Parameters")
@export var _inner_radius: float = 0.1:
	set(val):
		if val > _outer_radius:
			_inner_radius = _outer_radius
			return
		_inner_radius = val
		var mat = _get_vignette_mat()
		if mat:
			mat.set_shader_parameter("inner_radius", val)

@export var _outer_radius: float = 1.:
	set(val):
		if val < _inner_radius:
			_outer_radius = _inner_radius
			return
		_outer_radius = val
		var mat = _get_vignette_mat()
		if mat:
			mat.set_shader_parameter("outer_radius", val)


@export var _vignette_strength: float = 1.:
	set(val):
		if val < 0:
			_vignette_strength = 0
			return
		_vignette_strength = val
		var mat = _get_vignette_mat()
		if mat:
			mat.set_shader_parameter("vignette_strength", val)


@export var _dither_strength: float = 0.3:
	set(val):
		_dither_strength = val
		var mat = _get_vignette_mat()
		if mat:
			mat.set_shader_parameter("dither_strength", val)


@export var _vignette_color: Color = Color(0.,0.,0.):
	set(val):
		_vignette_color = val
		var mat = _get_vignette_mat()
		if mat:
			mat.set_shader_parameter("vignette_color", val)
