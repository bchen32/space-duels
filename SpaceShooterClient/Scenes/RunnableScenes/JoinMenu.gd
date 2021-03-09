extends Spatial

enum search_distance {close, default, far, worldwide}

onready var back_button = $UI/VBoxContainer/Back
onready var lobby_list = $UI/VBoxContainer/Scroll/VBoxContainer

func _ready():
#	steam
	Steam.connect('lobby_match_list', self, '_on_lobby_match_list')
	Steam.connect('lobby_joined', self, '_on_lobby_joined')
#	buttons
	back_button.connect('pressed', self, '_on_back_pressed')
#	search for lobbies
	Steam.addRequestLobbyListDistanceFilter(search_distance.worldwide)
	Steam.addRequestLobbyListStringFilter('publicity', 'public', 0)
	print('Requesting lobby list')
	Steam.requestLobbyList()

func _input(event):
	if event.is_action_released('ui_cancel'):
		Globals.go_back()

func join_lobby(lobby_id):
	print(lobby_id)
	Steam.joinLobby(lobby_id)

func _get_lobby_enemy():
	Globals.lobby_enemy_id = Steam.getLobbyMemberByIndex(Globals.lobby_id, 0)

func _make_p2p_handshake():
	print('Sending P2P handshake')
#	_send_P2P_Packet(var2bytes({'message' : 'handshake', 'from' : Globals.steam_id}))

func _on_lobby_match_list(lobbies):
	for lobby_id in lobbies:
		var host_name = Steam.getLobbyData(lobby_id, 'host_name')
		var lobby_button = Button.new()
		lobby_button.set_text(host_name)
		lobby_button.connect('pressed', self, 'join_lobby', [lobby_id])
		lobby_list.add_child(lobby_button)

func _on_lobby_joined(lobby_id, _permissions, _locked, _response):
	Globals.lobby_id = lobby_id
	_get_lobby_enemy()
	_make_p2p_handshake()

func _on_back_pressed():
	Globals.go_back()


