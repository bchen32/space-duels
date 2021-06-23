extends Spatial

enum lobby_visibility {private, friends, public, invisible}

onready var public_button = $UI/Column/Row/Column/Public
onready var private_button = $UI/Column/Row/Column/Private
onready var back_button = $UI/Column/Back

var publicity = ''
var max_players = 2

func _ready():
#	steam
	Steam.connect('lobby_created', self, '_on_lobby_created')
#	buttons
	public_button.connect('pressed', self, '_on_public_pressed')
	private_button.connect('pressed', self, '_on_private_pressed')
	back_button.connect('pressed', self, '_on_back_pressed')

func create_lobby():
	if Globals.lobby_id == 0:
		Steam.createLobby(lobby_visibility.public, max_players)

func _on_lobby_created(connect, lobby_id):
	if connect == 1:
		Globals.lobby_id = lobby_id
		Globals.host = true
		print('Created a lobby: ' + str(Globals.lobby_id))
		Steam.setLobbyData(lobby_id, 'host_name', Globals.steam_name)
		Steam.setLobbyData(lobby_id, 'publicity', publicity)
		var relay = Steam.allowP2PPacketRelay(true)
		print('Allowing Steam to be relay backup: ' + str(relay))
		print(Steam.getLobbyData(lobby_id, 'publicity'))
		Globals.go_lobby()

func _input(event):
	if event.is_action_released('ui_cancel'):
		Globals.go_back()

func _on_public_pressed():
	publicity = 'public'
	create_lobby()

func _on_private_pressed():
	publicity = 'private'
	create_lobby()

func _on_back_pressed():
	Globals.go_back()


