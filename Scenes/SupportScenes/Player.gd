extends KinematicBody

export var damage = 1
export var height = 8.5
export var radius = 1
export var mass = 1000
export var thrust = 50000
export var torque = Vector3(10000, 1000, 10000)
var moment_inertia = Vector3(0.25 * mass * radius * radius + mass * height * height / 12, 0.5 * mass * radius * radius, 0.25 * mass * radius * radius + mass * height * height / 12)
var accel = thrust / mass
var turn_accel = torque / moment_inertia

var velocity = Vector3()
var angular_velocity = Vector3()

onready var crosshair_circle = $CrosshairCircle
onready var crosshair_cross = $CrosshairCross
onready var shoot_area_circle = $ShootAreaCircle
onready var camera = $Camera
onready var shoot_area = $Camera/ShootArea
onready var vision_area = $Camera/VisionArea
onready var gun_pivots = [$Spaceship/GunPivotTop, $Spaceship/GunPivotBottom]

var enemy_marker_scene = preload('res://Scenes/SupportScenes/EnemyMarker.tscn')
var enemy_markers = []

func look_at_no_spin(eye, target):
	var y_vector = target.normalized()
	eye.global_transform.basis.y = y_vector

func signed_angle(from, to, up):
#	signed angle between 2 vectors using the 3rd as the 'up' vector
	if from.cross(to).dot(up) < 0:
		return -from.angle_to(to)
	return from.angle_to(to)

func stop(vel, max_accel):
#	smoothly stops ship in case the remaining velocity is not a multiple of the accel
	if vel > 0:
		return max(-vel, -max_accel)
	return min(-vel, max_accel)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pass

func _physics_process(delta):
#	shooting area
	var collision_shape = ConvexPolygonShape.new()
	var collision_points_octagon = [Vector3()]
	var fov_shoot_theta = 0.02
	var fov_shoot_length = 10000
	var octagon_collision_radius = atan(fov_shoot_theta) * fov_shoot_length
	var mouse_pos = crosshair_circle.rect_position + (crosshair_circle.rect_size / 2)
	var mouse_vector = (camera.project_ray_normal(mouse_pos) - transform.basis.y) * fov_shoot_length
	var mouse_vector_x = mouse_vector.dot(transform.basis.x) / (transform.basis.x.length() * transform.basis.x.length())
	var mouse_vector_z = mouse_vector.dot(transform.basis.z) / (transform.basis.z.length() * transform.basis.z.length())
	for i in range(8):
		collision_points_octagon.append(Vector3(mouse_vector_x + octagon_collision_radius * cos(i * PI / 4), fov_shoot_length, mouse_vector_z + octagon_collision_radius * sin(i * PI / 4)))
	collision_shape.points = collision_points_octagon
	shoot_area.get_node('CollisionShape').set_shape(collision_shape)
	var gun_look_at = camera.project_ray_normal(mouse_pos) * fov_shoot_length * 2
	look_at_no_spin(gun_pivots[0], gun_look_at)
	look_at_no_spin(gun_pivots[1], gun_look_at)
#	movement controls
	if Input.is_action_pressed('fire'):
		var bodies = shoot_area.get_overlapping_bodies()
		for body in bodies:
			if body == self:
				continue
			body.health -= damage
	if Input.is_action_pressed('pitch_up'):
		if Input.is_action_pressed('stop_modifier'):
			angular_velocity.x += stop(angular_velocity.x, turn_accel.x * delta)
		else:
			angular_velocity.x += turn_accel.x * delta
	if Input.is_action_pressed('pitch_down'):
		if Input.is_action_pressed('stop_modifier'):
			angular_velocity.x += stop(angular_velocity.x, turn_accel.x * delta)
		else:
			angular_velocity.x += -turn_accel.x * delta
	if Input.is_action_pressed('yaw_right'):
		if Input.is_action_pressed('stop_modifier'):
			angular_velocity.z += stop(angular_velocity.z, turn_accel.z * delta)			
		else:
			angular_velocity.z += -turn_accel.z * delta
	if Input.is_action_pressed('yaw_left'):
		if Input.is_action_pressed('stop_modifier'):
			angular_velocity.z += stop(angular_velocity.z, turn_accel.z * delta)			
		else:
			angular_velocity.z += turn_accel.z * delta
	if Input.is_action_pressed('roll_cw'):
		if Input.is_action_pressed('stop_modifier'):
			angular_velocity.y += stop(angular_velocity.y, turn_accel.y * delta)
		else:
			angular_velocity.y += turn_accel.y * delta
	if Input.is_action_pressed('roll_ccw'):
		if Input.is_action_pressed('stop_modifier'):
			angular_velocity.y += stop(angular_velocity.y, turn_accel.y * delta)
		else:
			angular_velocity.y += -turn_accel.y * delta
	if Input.is_action_pressed('thrust'):
		velocity += transform.basis.y * accel * delta
	if Input.is_action_pressed('ui_cancel'):
		velocity = Vector3()
		angular_velocity = Vector3()
		transform = Transform.IDENTITY
	rotate_object_local(Vector3(1, 0, 0), angular_velocity.x * delta)
	rotate_object_local(Vector3(0, 1, 0), angular_velocity.y * delta)
	rotate_object_local(Vector3(0, 0, 1), angular_velocity.z * delta)
	transform = transform.orthonormalized()
	var move_collision = move_and_collide(velocity * delta)
	if move_collision:
		queue_free()

func _process(_delta):
	var mouse_pos = get_viewport().get_mouse_position()
	crosshair_circle.rect_position = (mouse_pos - (get_viewport().size / 2) + (crosshair_circle.rect_size / 2)).clamped(min(get_viewport().size.x, get_viewport().size.y) * 1 / 16) + (get_viewport().size / 2) - (crosshair_circle.rect_size / 2)
	crosshair_cross.rect_position = mouse_pos
	for enemy_marker in enemy_markers:
		enemy_marker.queue_free()
	enemy_markers = []
	var bodies = vision_area.get_overlapping_bodies()
	for body in bodies:
		if body == self:
			continue
		var enemy_coord = camera.unproject_position(body.global_transform.origin)
		var enemy_marker = enemy_marker_scene.instance()
		enemy_marker.rect_size = Vector2(50, 50)
		enemy_marker.rect_position = enemy_coord - (enemy_marker.rect_size / 2)
		enemy_markers.append(enemy_marker)
		add_child(enemy_marker)
	
	
