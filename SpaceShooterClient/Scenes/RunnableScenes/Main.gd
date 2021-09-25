extends Spatial

var player_scene = preload('res://Scenes/InstanceScenes/Player.tscn')
var enemy_player_scene = preload('res://Scenes/InstanceScenes/EnemyPlayer.tscn')

func _ready():
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

func _physics_process(_delta):
	pass
