extends KinematicBody

export var health = 144
export var velocity = Vector3()


func _physics_process(delta):
	if health <= 0:
		print_debug("Dead")
		queue_free()
	var move_collision = move_and_collide(velocity * delta)
	if move_collision:
		queue_free()
		print_debug("Obstacle collide")
