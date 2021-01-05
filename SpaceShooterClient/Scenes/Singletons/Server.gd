extends Node

var peer = NetworkedMultiplayerENet.new()
var ip = '127.0.0.1'
var port = 42101

func _ready():
	connect_server()

func connect_server():
	peer.create_client(ip, port)
	get_tree().set_network_peer(peer)
	peer.connect('connection_succeeded', self, '_on_connection_succeeded')
	peer.connect('connection_failed', self, '_on_connection_failed')

func _on_connection_succeeded():
	print('Connection succeeded')

func _on_connection_failed():
	print('Connection failed')
