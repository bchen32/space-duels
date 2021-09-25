extends Node

# Steam variables
var steam_id = 0
var steam_name = ''

# Lobby vars
var lobby_id = 0
var lobby_enemy_id = 0
var host = false

# P2P vars
var p2p_channel = 0
var p2p_data = {}
var ping = 0

# Scene paths
export var main_menu_path = 'res://Scenes/RunnableScenes/MainMenu.tscn'
export var lobby_menu_path = 'res://Scenes/RunnableScenes/LobbyMenu.tscn'
export var main_path = 'res://Scenes/RunnableScenes/Main.tscn'

# Debug vars
export var screenshot_mode = false
export var verbose_prints = true
export var print_frequency = 10
var frame_counter = 0


# Constants
const UNRELIABLE = 0
const UNRELIABLE_NO_DELAY = 0
const RELIABLE = 2
const RELIABLE_BUFFER = 3

func _ready():
	var init = Steam.steamInit()
	print(init)
	if init['status'] != 1:
		print('Failed to initialize Steam. ' + str(init['verbal']))
		get_tree().quit()
	print('Initialized')
	steam_id = Steam.getSteamID()
	steam_name = Steam.getPersonaName()
	# Steam signals
	Steam.connect('join_requested', self, '_on_join_requested')
	Steam.connect('lobby_joined', self, '_on_lobby_joined')
	check_command_line()

# Utility functions
func go_back():
	get_tree().change_scene(main_menu_path)

func go_lobby():
	get_tree().change_scene(lobby_menu_path)

func go_main(send_start_packet):
	get_tree().change_scene(main_path)
	if send_start_packet:
		send_p2p_packet(RELIABLE, {'type' : 'start', 'from' : steam_id})

func toggle_prompt(prompt):
	if !prompt.visible:
		prompt.popup()
	else:
		prompt.hide()

func alert(text, title):
	var dialog = AcceptDialog.new()
	dialog.dialog_text = text
	dialog.window_title = title
	dialog.connect('modal_closed', dialog, 'queue_free')
	var scene_tree = Engine.get_main_loop()
	scene_tree.current_scene.add_child(dialog)
	dialog.popup_centered()

# Steam functions
func check_command_line():
	var cmd_args = OS.get_cmdline_args()
	var lobby_invite_arg = false
	if cmd_args.size() > 0:
		for arg in cmd_args:
			print('Command line: ' + str(arg))
			if lobby_invite_arg:
				join_lobby(int(arg))
			if arg == '+connect_lobby':
				lobby_invite_arg = true

func join_lobby(new_lobby_id):
	Steam.joinLobby(new_lobby_id)

func leave_lobby():
	if lobby_id != 0:
		Steam.leaveLobby(lobby_id)
		Steam.closeP2PSessionWithUser(lobby_enemy_id)
		lobby_id = 0
		lobby_enemy_id = 0
		host = false
		print('Lobby left, p2p closed, IDs reset')

func display_message(chat_box, message):
	chat_box.add_text('\n' + str(message))

func send_message(chat_box, message_box):
	var message = message_box.get_text()
	if !message:
		return
	var send_status = Steam.sendLobbyChatMsg(Globals.lobby_id, message)
	if !send_status:
		display_message(chat_box, 'Error...message failed to send')
	message_box.clear()

# P2P functions
func send_ping(send_type, is_sender):
	send_p2p_packet(send_type, {'type' : 'ping', 'send_type' : send_type, 'is_sender' : is_sender, 'send_time' : OS.get_ticks_msec()})

func make_p2p_handshake():
	send_p2p_packet(RELIABLE, {'type' : 'handshake', 'from' : steam_id})

func read_p2p_packet():
	var packet_size = Steam.getAvailableP2PPacketSize(0)
	if packet_size > 0:
		var packet = Steam.readP2PPacket(packet_size, 0)
		if packet.empty():
			print('WARNING: read an empty packet with non-zero size!')
#		var packet_id = str(packet.steamIDRemote)
#		var packet_code = str(packet.data[0])
		var readable = bytes2var(packet.data.subarray(1, packet_size - 1))
#		Debug prints
		if verbose_prints and frame_counter == 0:
			print('Packet: ' + str(readable))
		if readable['type'] == 'ping':
			if readable['is_sender']:
				print('Ping received, sending back...')
				send_ping(readable['send_type'], false)
			else:
				print('Round trip ping: ' + str(OS.get_ticks_msec() - readable['send_time']))
		elif readable['type'] == 'handshake':
			print('Handshake received')
		elif readable['type'] == 'start':
			go_main(false)
			print('Starting...')
		elif readable['type'] == 'player':
			p2p_data = readable

func send_p2p_packet(send_type, packet_data):
	var data = PoolByteArray()
	data.append(256)
	data.append_array(var2bytes(packet_data))
	Steam.sendP2PPacket(lobby_enemy_id, data, send_type, p2p_channel)

# Steam signals
func _on_join_requested(join_lobby_id, friend_id):
	var host_name = Steam.getFriendPersonaName(friend_id)
	print('Joining ' + str(host_name))
	join_lobby(join_lobby_id)

func _on_lobby_joined(new_lobby_id, _permissions, _locked, response):
	if !host:
		print('Joined')
		if response != 1:
			Globals.alert('Unsuccessful, please check the join code', 'Error')
			return
		lobby_id = new_lobby_id
#		Get enemy id
		lobby_enemy_id = Steam.getLobbyMemberByIndex(lobby_id, 0)
		make_p2p_handshake()
		go_lobby()

func _physics_process(_delta):
	# Debug print frequency limiter
	frame_counter += 1
	if frame_counter == print_frequency:
		frame_counter = 0

func _process(_delta):
	Steam.run_callbacks()
	var num_packets = Steam.getAvailableP2PPacketSize(0)
	for _packet_ind in num_packets:
		read_p2p_packet()
