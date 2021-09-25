extends KinematicBody

func _ready():
	pass

func _physics_process(_delta):
	if Globals.p2p_data:
		transform = Globals.p2p_data['transform']
