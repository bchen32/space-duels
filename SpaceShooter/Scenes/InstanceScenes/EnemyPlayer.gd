extends KinematicBody

func _physics_process(_delta):
	if Globals.p2p_data:
		transform = Globals.p2p_data['transform']
