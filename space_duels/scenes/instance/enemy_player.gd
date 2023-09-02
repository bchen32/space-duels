extends KinematicBody

# Nodes
onready var lasers = [$Spaceship/GunPivotTop/LaserTop, $Spaceship/GunPivotBottom/LaserBottom]


func _physics_process(_delta):
	var data = Globals.p2p_data
	if data:
		transform = data["transform"]
		for laser in lasers:
			laser.visible = data["shooting"]
		if data["death"]:
			queue_free()
