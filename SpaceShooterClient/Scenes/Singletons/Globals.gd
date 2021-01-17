extends Node

# Steam variables
var owned = false
var online = false
var steam_id = 0

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
	
	# Check if account owns the game
	if not owned:
		print('Game not owned')
		get_tree().quit()

func _process(_delta):
	Steam.run_callbacks()
