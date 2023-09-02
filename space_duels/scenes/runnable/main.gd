extends Spatial

var player_scene = preload("res://scenes/instance/player.tscn")
var enemy_player_scene = preload("res://scenes/instance/enemy_player.tscn")


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var player = player_scene.instance()
	var enemy = enemy_player_scene.instance()
	if Globals.host:
		Globals.send_ping(Globals.UNRELIABLE_NO_DELAY, true)
		player.translation = Vector3(100, 0, 0)
		enemy.translation = Vector3(-100, 0, 0)
	else:
		player.translation = Vector3(-100, 0, 0)
		enemy.translation = Vector3(100, 0, 0)
	add_child(player)
	add_child(enemy)
