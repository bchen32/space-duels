extends KinematicBody

# Nodes
onready var crosshair_circle = $Overlay/CrosshairCircle
onready var crosshair_cross = $Overlay/CrosshairCross
onready var shoot_area_circle = $Overlay/ShootAreaCircle
onready var camera = $Camera
onready var vision_area = $Camera/VisionArea
onready var gun_pivots = [$Spaceship/GunPivotTop, $Spaceship/GunPivotBottom]
onready var lasers = [$Spaceship/GunPivotTop/LaserTop, $Spaceship/GunPivotBottom/LaserBottom]

# Physical characteristics
export var health = 500
export var damage = 1
export var height = 8.5
export var radius = 1
export var mass = 1000
export var thrust = 50000
export var torque = Vector3(10000, 1000, 10000)
export var ang_vel_max = Vector3(PI, 4 * PI, PI)

var moment_inertia = Vector3(
	0.25 * mass * radius * radius + mass * height * height / 12,
	0.5 * mass * radius * radius,
	0.25 * mass * radius * radius + mass * height * height / 12
)
var accel = thrust / mass
var turn_accel = torque / moment_inertia

# Vel and angular vel
var velocity = Vector3(0, 0, 0)
var angular_velocity = Vector3()

var enemy_marker_scene = preload("res://scenes/instance/enemy_marker.tscn")
var enemy_markers = []


func stop(basis, max_accel):
	# Smoothly stops ship in case the remaining velocity is not a multiple of the accel
	var projection_factor = basis.dot(angular_velocity) / (basis.length() * basis.length())
	if projection_factor > 0:
		return max(-projection_factor, -max_accel)
	return min(-projection_factor, max_accel)


func look_at_no_spin(eye, target):
	# Similar to the look at function, but not spinning the object
	var y_vector = target.normalized()
	eye.global_transform.basis.y = y_vector


func _ready():
	if Globals.screenshot_mode:
		$Overlay.hide()


func _physics_process(delta):
	var shooting = false
	var hit = false
	var death = false

	for laser in lasers:
		laser.visible = false

	# Point guns at target
	var mouse_pos = crosshair_circle.rect_position + (crosshair_circle.rect_size / 2)
	var gun_look_at = camera.project_ray_normal(mouse_pos)
	var pivot_points = [gun_pivots[0].global_transform.origin, gun_pivots[1].global_transform.origin]
	var gun_endpoints = [pivot_points[0] + gun_look_at * 50000, pivot_points[1] + gun_look_at * 50000]
	look_at_no_spin(gun_pivots[0], gun_look_at)
	look_at_no_spin(gun_pivots[1], gun_look_at)
	# Controls
	if Input.is_action_pressed("fire"):
		shooting = true
		for laser in lasers:
			laser.visible = true
		var bodies = vision_area.get_overlapping_bodies()
		for body in bodies:
			if body == self or body.get_collision_layer() != 1:
				continue
			# Raycast from each gun pivot to check for hit
			var space_state = get_world().direct_space_state
			var results = [{}, {}]
			results[0] = space_state.intersect_ray(
				pivot_points[0], gun_endpoints[0], [self]
			)
			results[1] = space_state.intersect_ray(
				pivot_points[1], gun_endpoints[1], [self]
			)
			for result in results:
				if result and result.collider == body:
					hit = true
	if Input.is_action_pressed("pitch_up"):
		if Input.is_action_pressed("stop_modifier"):
			angular_velocity += stop(transform.basis.x, turn_accel.x * delta) * transform.basis.x
		else:
			angular_velocity += transform.basis.x * turn_accel.x * delta
	if Input.is_action_pressed("pitch_down"):
		if Input.is_action_pressed("stop_modifier"):
			angular_velocity += stop(transform.basis.x, turn_accel.x * delta) * transform.basis.x
		else:
			angular_velocity -= transform.basis.x * turn_accel.x * delta
	if Input.is_action_pressed("yaw_left"):
		if Input.is_action_pressed("stop_modifier"):
			angular_velocity += stop(transform.basis.z, turn_accel.z * delta) * transform.basis.z
		else:
			angular_velocity += transform.basis.z * turn_accel.z * delta
	if Input.is_action_pressed("yaw_right"):
		if Input.is_action_pressed("stop_modifier"):
			angular_velocity += stop(transform.basis.z, turn_accel.z * delta) * transform.basis.z
		else:
			angular_velocity -= transform.basis.z * turn_accel.z * delta
	if Input.is_action_pressed("roll_cw"):
		if Input.is_action_pressed("stop_modifier"):
			angular_velocity += stop(transform.basis.y, turn_accel.y * delta) * transform.basis.y
		else:
			angular_velocity += transform.basis.y * turn_accel.y * delta
	if Input.is_action_pressed("roll_ccw"):
		if Input.is_action_pressed("stop_modifier"):
			angular_velocity += stop(transform.basis.y, turn_accel.y * delta) * transform.basis.y
		else:
			angular_velocity -= transform.basis.y * turn_accel.y * delta

	angular_velocity = Vector3(
		clamp(angular_velocity.x, -ang_vel_max.x, ang_vel_max.x),
		clamp(angular_velocity.y, -ang_vel_max.y, ang_vel_max.y),
		clamp(angular_velocity.z, -ang_vel_max.z, ang_vel_max.z)
	)

	if Input.is_action_pressed("thrust"):
		velocity += transform.basis.y * accel * delta

	if Globals.verbose_prints and Globals.frame_counter == 0:
		print_debug(velocity)

	# Move
	var rotation_speed = angular_velocity.length()
	var rotation_axis = angular_velocity.normalized()
	if !angular_velocity.is_equal_approx(Vector3()):
		rotate(rotation_axis, rotation_speed * delta)
	transform = transform.orthonormalized()
	# Check collisions and move
	var move_collision = move_and_collide(velocity * delta)

	# Handle death
	if health <= 0 or move_collision:
		death = true
		print_debug("Die")
		queue_free()

	# Handle p2p data
	if Globals.p2p_data:
		health -= Globals.p2p_data["damage"]
	Globals.send_p2p_packet(
		Globals.UNRELIABLE_NO_DELAY,
		{
			"type": "player",
			"transform": transform,
			"shooting": shooting,
			"damage": damage if hit else 0,
			"death": death
		}
	)

	# Mark visible enemies
	for enemy_marker in enemy_markers:
		enemy_marker.queue_free()
	enemy_markers = []
	var bodies = vision_area.get_overlapping_bodies()
	for body in bodies:
		if body == self or body.get_collision_layer() != 1:
			continue
		# Raycast check for visibility
		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(
			camera.global_transform.origin, body.global_transform.origin, [self]
		)
		if result and result.collider == body:
			var enemy_coord = camera.unproject_position(body.global_transform.origin)
			var enemy_marker = enemy_marker_scene.instance()
			enemy_marker.rect_size = Vector2(50, 50)
			enemy_marker.rect_position = enemy_coord - (enemy_marker.rect_size / 2)
			enemy_markers.append(enemy_marker)
			if !Globals.screenshot_mode:
				add_child(enemy_marker)


func _process(_delta):
	# Constrain crosshair
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().get_visible_rect().size
	crosshair_circle.rect_position = (
		(mouse_pos - (viewport_size / 2) + (crosshair_circle.rect_size / 2)).clamped(
			viewport_size.y / 16
		)
		+ (viewport_size / 2)
		- (crosshair_circle.rect_size / 2)
	)
	crosshair_cross.rect_position = mouse_pos
