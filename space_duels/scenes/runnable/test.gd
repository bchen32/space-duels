extends Spatial

var player_scene = preload("res://scenes/instance/player.tscn")
var enemy_player_scene = preload("res://scenes/instance/enemy_player.tscn")
var player
var enemy

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	player = player_scene.instance()
	enemy = enemy_player_scene.instance()
	player.translation = Vector3(100, 0, 0)
	enemy.translation = Vector3(100, 20, 0)
	add_child(player)
	add_child(enemy)

func _physics_process(_delta):
	if Input.is_action_pressed('ui_up'):
		player.camera.current = true
	if Input.is_action_pressed('ui_down'):
		$OutCam.current = true
	if Input.is_action_just_pressed('ui_cancel'):
		get_tree().reload_current_scene()