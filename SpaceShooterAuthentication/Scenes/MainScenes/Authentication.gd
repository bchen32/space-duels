extends Node

var peer = NetworkedMultiplayerENet.new()
var port = 42101
var max_servers = 5

func _ready():
	init_server()

func init_server():
	peer.create_server(port, max_servers)
	get_tree().set_network_peer(peer)
	print('Auth server initalized')
	peer.connect('peer_connected', self, '_peer_connected')
	peer.connect('peer_disconnected', self, '_peer_disconnected')

func _peer_connected(peer_id):
	print(str(peer_id) + ' connected')

func _peer_disconnected(peer_id):
	print(str(peer_id) + ' disconnected')
