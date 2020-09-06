extends KinematicBody

export var height = 8.5
export var radius = 1
export var mass = 1000
export var thrust = 50000
export var torque = Vector3(10000, 1000, 10000)
var moment_inertia = Vector3(0.25 * mass * radius * radius + mass * height * height / 12, 0.5 * mass * radius * radius, 0.25 * mass * radius * radius + mass * height * height / 12)
var accel = thrust / mass
var turn_accel = torque / moment_inertia


export var crosshair = preload("res://assets/Crosshair.png")

var velocity = Vector3()
var angular_velocity = Vector3()

var stop_step = 0
# 0 is stopping non roll rotation, 1 is aligning roll, 2 is aligning pitch/yaw, 3 is thrusting in opposite direction

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

func full_stop():
#	calculates the roll and pitch/yaw angle necessary to get the ship to face opposite to its velocity
	var direction = -velocity.normalized()
	var facing = transform.basis.y
	var rotation_plane = Plane(Vector3(), facing, direction)
	if rotation_plane.normal.is_equal_approx(Vector3()):
		return Vector3(PI, 0, 0)
	var roll_angle1 = signed_angle(transform.basis.x, rotation_plane.normal, facing)
	var roll_angle2 = signed_angle(-transform.basis.x, rotation_plane.normal, facing)
	var roll_angle3 = signed_angle(transform.basis.z, rotation_plane.normal, facing)
	var roll_angle4 = signed_angle(-transform.basis.z, rotation_plane.normal, facing)
	var abs1 = abs(roll_angle1)
	var abs2 = abs(roll_angle2)
	var abs3 = abs(roll_angle3)
	var abs4 = abs(roll_angle4)
	var angle = signed_angle(facing, direction, rotation_plane.normal)
	if abs1 <= abs2 && abs1 <= abs3 && abs1 <= abs4:
		return Vector3(angle, roll_angle1, 0)
	if abs2 <= abs1 && abs2 <= abs3 && abs2 <= abs4:
		return Vector3(-angle, roll_angle2, 0)
	if abs3 <= abs1 && abs3 <= abs2 && abs3 <= abs4:
		return Vector3(0, roll_angle3, angle)
	if abs4 <= abs1 && abs4 <= abs2 && abs4 <= abs3:
		return Vector3(0, roll_angle4, -angle)

func roll_align():
#	given a ship that has no pitch/yaw, return the time floating necessary
	var direction = -velocity.normalized()
	var facing = transform.basis.y
	var rotation_plane = Plane(Vector3(), facing, direction)
	if rotation_plane.normal.is_equal_approx(Vector3()):
		return Vector3(PI, 0, 0)
	var roll_angles = []
	roll_angles.append(signed_angle(transform.basis.x, rotation_plane.normal, facing))
	roll_angles.append(signed_angle(-transform.basis.x, rotation_plane.normal, facing))
	roll_angles.append(signed_angle(transform.basis.z, rotation_plane.normal, facing))
	roll_angles.append(signed_angle(-transform.basis.z, rotation_plane.normal, facing))
#	var abs1 = abs(roll_angle1)
#	var abs2 = abs(roll_angle2)
#	var abs3 = abs(roll_angle3)
#	var abs4 = abs(roll_angle4)
#	var y_angle = roll_angle4
#	if abs1 <= abs2 && abs1 <= abs3 && abs1 <= abs4:
#		y_angle = roll_angle1
#	if abs2 <= abs1 && abs2 <= abs3 && abs2 <= abs4:
#		y_angle = roll_angle2
#	if abs3 <= abs1 && abs3 <= abs2 && abs3 <= abs4:
#		y_angle = roll_angle3
	var time_floats = []
	for i in range(4):
		var time_accel = abs(angular_velocity.y / turn_accel.y)
		var distance_accel = 0.5 * turn_accel.y * time_accel * time_accel + angular_velocity.y * time_accel
		if angular_velocity.y > 0:
	#		need negative accel to stop
			distance_accel = -0.5 * turn_accel.y * time_accel * time_accel + angular_velocity.y * time_accel
		var distance_float = fposmod(roll_angles[i] - distance_accel, -2 * PI)
		if angular_velocity.y > 0:
			distance_float = fposmod(roll_angles[i] - distance_accel, 2 * PI)
		var time_float = distance_float / angular_velocity.y
		time_floats.append(time_float)
	var min_time_float = time_floats[0]
	for i in range(4):
		min_time_float = min(min_time_float, time_floats[i])
	return min_time_float
	
	
	
	

func _ready():
	Input.set_custom_mouse_cursor(crosshair)

func _physics_process(delta):
#	movement controls
	if Input.is_action_pressed("pitch_up"):
		if Input.is_action_pressed("stop_modifier"):
			angular_velocity.x += stop(angular_velocity.x, turn_accel.x * delta)
		else:
			angular_velocity.x += turn_accel.x * delta
	if Input.is_action_pressed("pitch_down"):
		if Input.is_action_pressed("stop_modifier"):
			angular_velocity.x += stop(angular_velocity.x, turn_accel.x * delta)
		else:
			angular_velocity.x += -turn_accel.x * delta
	if Input.is_action_pressed("yaw_right"):
		if Input.is_action_pressed("stop_modifier"):
			angular_velocity.z += stop(angular_velocity.z, turn_accel.z * delta)			
		else:
			angular_velocity.z += -turn_accel.z * delta
	if Input.is_action_pressed("yaw_left"):
		if Input.is_action_pressed("stop_modifier"):
			angular_velocity.z += stop(angular_velocity.z, turn_accel.z * delta)			
		else:
			angular_velocity.z += turn_accel.z * delta
	if Input.is_action_pressed("roll_cw"):
		if Input.is_action_pressed("stop_modifier"):
			angular_velocity.y += stop(angular_velocity.y, turn_accel.y * delta)
		else:
			angular_velocity.y += turn_accel.y * delta
	if Input.is_action_pressed("roll_ccw"):
		if Input.is_action_pressed("stop_modifier"):
			angular_velocity.y += stop(angular_velocity.y, turn_accel.y * delta)
		else:
			angular_velocity.y += -turn_accel.y * delta
	if Input.is_action_pressed("thrust"):
		if Input.is_action_pressed("stop_modifier"):
			if !velocity.is_equal_approx(Vector3()):
				if stop_step == 0:
#					stop non roll velocity
					if !is_equal_approx(angular_velocity.x, 0) or !is_equal_approx(angular_velocity.z, 0):
						angular_velocity.x += stop(angular_velocity.x, turn_accel.x * delta)
						angular_velocity.z += stop(angular_velocity.z, turn_accel.z * delta)
					else:
						stop_step = 1
				if stop_step == 1:
#					align roll
					if !is_equal_approx(angular_velocity.y, 0):
						var time_float = roll_align()
						if time_float <= delta:
							angular_velocity.y += stop(angular_velocity.y, turn_accel.y * delta)
					else:
						stop_step = 2
						var angles = full_stop()
						rotate_object_local(Vector3(0, 1, 0), angles.y)
				if stop_step == 2:
#					align pitch/yaw
					print()
				if stop_step == 3:
#					thrust
					velocity += transform.basis.y * accel * delta
		else:
			velocity += transform.basis.y * accel * delta
	if Input.is_action_pressed("ui_cancel"):
		velocity = Vector3()
		angular_velocity = Vector3()
		transform = Transform.IDENTITY
	rotate_object_local(Vector3(1, 0, 0), angular_velocity.x * delta)
	rotate_object_local(Vector3(0, 1, 0), angular_velocity.y * delta)
	rotate_object_local(Vector3(0, 0, 1), angular_velocity.z * delta)
	transform = transform.orthonormalized()
	translation += velocity * delta
