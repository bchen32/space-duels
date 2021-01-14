extends Node2D

enum lobby_visibility {private, friends, public, invisible}
enum search_distance {close, default, far, worldwide}

var steam_lobby_id = 0
var lobby_members = []
var lobby_invite_arg = false

onready var steam_name = $SteamName
onready var lobby_name_edit = $Create/LobbyNameEdit

var _blank

func _ready():
	steam_name.text = Globals.steam_name
	_blank = Steam.connect('lobby_created', self, '_on_lobby_created')
	_blank = Steam.connect('lobby_match_list', self, '_on_lobby_match_list')
	_blank = Steam.connect('lobby_joined', self, '_on_lobby_joined')
	_blank = Steam.connect('lobby_chat_update', self, '_on_lobby_chat_update')
	_blank = Steam.connect('lobby_message', self, '_on_lobby_message')
	_blank = Steam.connect('lobby_data_update', self, '_on_lobby_data_update')
	_blank = Steam.connect('lobby_invite', self, '_on_lobby_invite')
	_blank = Steam.connect('join_requested', self, '_on_lobby_join_requested')
	_blank = Steam.connect('p2p_session_request', self, '_on_p2p_session_request')
	_blank = Steam.connect('p2p_session_blank_fail', self, '_on_p2p_session_blank_fail')
	# check for command line arguments
	check_command_line()

func _on_lobby_created(connect, lobby_id):
	if connect == 1:
		steam_lobby_id = lobby_id
		print('Created a lobby: ' + str(steam_lobby_id))
		_blank = Steam.setLobbyData(lobby_id, 'name', lobby_name_edit.text)
		_blank = Steam.setLobbyData(lobby_id, 'mode', 'GodotSteam test')
		var relay = Steam.allowP2PPacketRelay(true)
		print('Allowing Steam to be relay backup: ' + str(relay))

func _create_lobby():
	if steam_lobby_id == 0:
		Steam.createLobby(lobby_visibility.public, 2)

func _on_create_pressed():
	pass # Replace with function body.

func _on_join_pressed():
	pass # Replace with function body.

func _on_start_pressed():
	pass # Replace with function body.

func _on_leave_pressed():
	pass # Replace with function body.

func check_command_line():
	var cmd_args = OS.get_cmdline_args()
	if cmd_args.size() > 0:
		for arg in cmd_args:
			print('Command line: ' + str(arg))
#			if lobby_invite_arg:
#				_join_Lobby(int(arg))
			if arg == '+connect_lobby':
				lobby_invite_arg = true
