class_name ClickRectangle extends BaseBehavior

@export var mesh: MeshInstance3D
@export var color: Color

@export var is_open: bool = false
@export var room_item: RoomStats.RoomLight = RoomStats.RoomLight.LAPTOP
@export var room_system: RoomStats = null

@onready var _given_color: Color = (mesh.mesh.surface_get_material(0) as StandardMaterial3D).albedo_color if mesh else Color(0,0,0);


var _pressed: bool = is_open

func _ready() -> void:
	assert(room_system)

	await room_system.ready
	room_system.update_room_state(room_item, is_open)
	_pressed = is_open
	if _pressed:
		_apply_object_effect(self.color)
	else:
		_apply_object_effect(_given_color)


func _apply_object_effect(color: Color):
	if mesh:
		var m: StandardMaterial3D = mesh.mesh.surface_get_material(0);
		m.albedo_color = color


func call_trigger():
	_pressed = !_pressed;
	if _pressed:
		_apply_object_effect(self.color)
	else:
		_apply_object_effect(_given_color)

	room_system.update_room_state(room_item, _pressed)



func enable_trigger():
	pass

func disable_trigger():
	pass

func hovered_reference():
	pass
