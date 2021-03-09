extends Control



var lobby_members = []
var lobby_invite_arg = false

func _ready():
	Steam.connect('lobby_match_list', self, '_on_lobby_match_list')
	Steam.connect('lobby_joined', self, '_on_lobby_joined')
	Steam.connect('lobby_chat_update', self, '_on_lobby_chat_update')
	Steam.connect('lobby_message', self, '_on_lobby_message')
	Steam.connect('lobby_data_update', self, '_on_lobby_data_update')
	Steam.connect('lobby_invite', self, '_on_lobby_invite')
	Steam.connect('join_requested', self, '_on_lobby_join_requested')
	Steam.connect('p2p_session_request', self, '_on_p2p_session_request')
	Steam.connect('p2p_session_blank_fail', self, '_on_p2p_session_blank_fail')
	# check for command line arguments
	check_command_line()

func check_command_line():
	var cmd_args = OS.get_cmdline_args()
	if cmd_args.size() > 0:
		for arg in cmd_args:
			print('Command line: ' + str(arg))
#			if lobby_invite_arg:
#				_join_Lobby(int(arg))
			if arg == '+connect_lobby':
				lobby_invite_arg = true
