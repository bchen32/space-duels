extends Node

# steam variables
var owned = false
var online = false
var steam_id = 0
var steam_name = ''

# lobby vars
var lobby_id = 0
var lobby_enemy_id = 0

# scene paths
export var main_menu_path = 'res://Scenes/RunnableScenes/MainMenu.tscn'
export var lobby_menu_path = 'res://Scenes/RunnableScenes/LobbyMenu.tscn'
export var join_menu_script_path = 'res://Scenes/RunnableScenes/JoinMenu.gd'

func _ready():
	var init = Steam.steamInit()
	print(init)
	if init['status'] != 1:
		print('Failed to initialize Steam. ' + str(init['verbal']))
		get_tree().quit()
	print('Initialized')
	owned = Steam.isSubscribed()
	online = Steam.loggedOn()
	steam_id = Steam.getSteamID()
	steam_name = Steam.getPersonaName()
	# Check if account owns the game
	if not owned:
		print('Game not owned')
		get_tree().quit()
	Steam.connect('join_requested', self, 'on_join_requested')

func go_back():
	get_tree().change_scene(main_menu_path)

func go_lobby():
	get_tree().change_scene(lobby_menu_path)

func _on_join_requested(join_lobby_id, friend_id):
	var host_name = Steam.getFriendPersonaName(friend_id)
	print('Joining ' + str(host_name))
	var join_menu_script = load(join_menu_script_path)
	join_menu_script.join_lobby(join_lobby_id)

func _process(_delta):
	Steam.run_callbacks()
