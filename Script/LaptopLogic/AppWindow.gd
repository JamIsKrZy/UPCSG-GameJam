extends CharacterBody2D

var draggingDistance
var dir
var dragging
var newPosition = Vector2()


var mouse_in = false

@export var use_screen_boundaries = true
@export var boundary_margin = 50  # Pixels from screen edge
@export var use_collision_check = true  # Check for StaticBody2D collisions


func _ready():
	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() && mouse_in:
			draggingDistance = position.distance_to(get_viewport().get_mouse_position())
			dir = (get_viewport().get_mouse_position() - position).normalized()
			dragging = true
			newPosition = get_viewport().get_mouse_position() - draggingDistance * dir
		else:
			dragging = false
			#
	elif event is InputEventMouseMotion:
		if dragging:
			newPosition = get_viewport().get_mouse_position() - draggingDistance * dir

func _physics_process(delta):
	if dragging:
		var target_position = newPosition

		# Apply screen boundaries if enabled
		if use_screen_boundaries:
			target_position = clamp_to_screen(target_position)

		# Calculate velocity
		velocity = (target_position - position) * Vector2(30, 30)

		# Move and check for collisions
		move_and_slide()

		# If collision check is enabled, prevent movement into walls
		if use_collision_check && get_slide_collision_count() > 0:
			# Get the last valid position before collision
			for i in get_slide_collision_count():
				var collision = get_slide_collision(i)
				# Push back slightly from the collision
				position -= collision.get_normal() * 2

func clamp_to_screen(target_pos: Vector2) -> Vector2:
	var screen_size = get_viewport_rect().size
	var clamped_pos = target_pos

	clamped_pos.x = clamp(target_pos.x, boundary_margin, screen_size.x - boundary_margin)
	clamped_pos.y = clamp(target_pos.y, boundary_margin, screen_size.y - boundary_margin)

	return clamped_pos

func _mouse_entered() -> void:
	print("asd")
	mouse_in = true

func _mouse_exited() -> void:
	print("asd")

	mouse_in = false
