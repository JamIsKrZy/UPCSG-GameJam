extends Node

enum CAMERA_STATE { LEFT, RIGHT, IDLE}

@export var camera_ref: PhantomCamera3D;
@export var camera_state: CAMERA_STATE

@export_group("Camera Attributes")
@export var max_left_angle: float = 0.;
@export var max_right_angle: float = 0.;
@export var transition_speed: float = 1.;

@export_group("Hide Slot Option")
@export var slot_node_ref: Control = null
@export var left_angle_bounds: float = -10.;
@export var right_angle_bounds: float = 10.;


func idle_screen() -> void:
	camera_state = CAMERA_STATE.IDLE;


func left_screen_is_hovered() -> void:
	camera_state = CAMERA_STATE.LEFT;



func right_screen_is_hovered() -> void:
	camera_state = CAMERA_STATE.RIGHT;




func _physics_process(delta: float) -> void:

	if slot_node_ref.is_active(): return
	if camera_state == CAMERA_STATE.IDLE: return

	var speed := deg_to_rad(transition_speed) * delta * 2

	if camera_state == CAMERA_STATE.LEFT:
		var target := deg_to_rad(max_left_angle)

		camera_ref.rotation.y = min(
			camera_ref.rotation.y + speed,
			target
		)
	else:
		var target := deg_to_rad(max_right_angle)

		camera_ref.rotation.y = max(
			camera_ref.rotation.y - speed,
			target
		)

	# print(camera_ref.rotation.y)
	# print(deg_to_rad(left_angle_bounds), " - ", deg_to_rad(right_angle_bounds))

	if camera_ref.rotation.y < deg_to_rad(left_angle_bounds) || camera_ref.rotation.y > deg_to_rad(right_angle_bounds):
		slot_node_ref.hide_and_lock();
	else:
		slot_node_ref.unhide_and_unlock();
