extends Spatial

enum search_distance {close, default, far, worldwide}

onready var lobby_list = $UI/Column/Scroll/Column
onready var refresh_button = $UI/Column/Refresh
onready var join_code = $UI/Column/Row/LobbyCode
onready var join_button = $UI/Column/Row/Join
onready var back_button = $UI/Column/Back

func _ready():
#	steam
	Steam.connect('lobby_match_list', self, '_on_lobby_match_list')
	Steam.connect('lobby_joined', self, '_on_lobby_joined')
#	buttons
	refresh_button.connect('pressed', self, '_on_refresh_pressed')
	join_button.connect('pressed', self, '_on_join_pressed')
	back_button.connect('pressed', self, '_on_back_pressed')
#	other signals
	join_code.connect('text_entered', self, '_on_join_entered')
#	search for lobbies
	refresh_lobby_list()

func join_lobby(lobby_id):
	Steam.joinLobby(lobby_id)

func join_private():
	var lobby_id = join_code.get_text()
	if lobby_id.is_valid_integer(): 
		lobby_id = int(lobby_id)
		join_lobby(lobby_id)
	else:
		Globals.alert('Code must be a number', 'Error')
	join_code.clear()

func refresh_lobby_list():
	for lobby_button in lobby_list.get_children():
		lobby_button.queue_free()
	Steam.addRequestLobbyListDistanceFilter(search_distance.worldwide)
	Steam.addRequestLobbyListStringFilter('publicity', 'public', 0)
	Steam.requestLobbyList()

func _input(event):
	if event.is_action_released('ui_cancel'):
		Globals.go_back()

func _on_lobby_match_list(lobbies):
	for lobby_id in lobbies:
		var host_name = Steam.getLobbyData(lobby_id, 'host_name')
		var lobby_button = Button.new()
		lobby_button.set_text(host_name)
		lobby_button.connect('pressed', self, 'join_lobby', [lobby_id])
		lobby_list.add_child(lobby_button)

func _on_lobby_joined(lobby_id, _permissions, _locked, response):
	if response != 1:
		Globals.alert('Unsuccessful, please check the join code', 'Error')
		return
	Globals.lobby_id = lobby_id
#	get enemy id
	Globals.lobby_enemy_id = Steam.getLobbyMemberByIndex(Globals.lobby_id, 0)
	Globals.make_p2p_handshake()
	Globals.go_lobby()

func _on_refresh_pressed():
	refresh_lobby_list()

func _on_join_pressed():
	join_private()

func _on_back_pressed():
	Globals.go_back()

func _on_join_entered(_text):
	join_private()
