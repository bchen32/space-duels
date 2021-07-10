extends Spatial

var player_scene = preload('res://Scenes/InstanceScenes/Player.tscn')


func _ready():
	var player1 = player_scene.instance()
	player1.translation = Vector3(100, 0, 0)
	var player2 = player_scene.instance()
	player2.translation = Vector3(-100, 0, 0)
	add_child(player1)
	add_child(player2)

func _physics_process(_delta):
	pass
