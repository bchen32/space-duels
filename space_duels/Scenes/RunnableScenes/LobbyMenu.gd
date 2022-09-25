extends Spatial

onready var lobby_id_label = $UI/Column/TopRow/Column/LobbyID
onready var copy = $UI/Column/TopRow/Column/Copy
onready var chat_box = $UI/Column/ChatPanel/ChatBox
onready var leave_button = $UI/Column/Leave
onready var leave_prompt = $UI/LeavePrompt
onready var leave_confirm = $UI/LeavePrompt/Column/Row/Confirm
onready var leave_cancel = $UI/LeavePrompt/Column/Row/Cancel
onready var message_box = $UI/Column/BottomRow/Message
onready var send_button = $UI/Column/BottomRow/Send
onready var start_button = $UI/Column/TopRow/Start


func _ready():
	# Steam
	Steam.connect("lobby_message", self, "_on_lobby_message")
	Steam.connect("lobby_chat_update", self, "_on_lobby_update")
	Steam.connect("p2p_session_request", self, "_on_p2p_session_request")
	Steam.connect("p2p_session_connect_fail", self, "_on_p2p_session_connect_fail")
	# Buttons
	copy.connect("pressed", self, "_on_copy_pressed")
	leave_button.connect("pressed", self, "_on_leave_pressed")
	leave_confirm.connect("pressed", self, "_on_leave_confirm_pressed")
	leave_cancel.connect("pressed", self, "_on_leave_cancel_pressed")
	send_button.connect("pressed", self, "_on_send_pressed")
	start_button.connect("pressed", self, "_on_start_pressed")
	# Other signals
	message_box.connect("text_entered", self, "_on_text_entered")
	# Other
	lobby_id_label.text = (
		"Lobby ID: "
		+ str(Globals.lobby_id)
		+ " ("
		+ Steam.getLobbyData(Globals.lobby_id, "publicity")
		+ ")"
	)


func _input(event):
	if event.is_action_released("ui_cancel"):
		Globals.toggle_prompt(leave_prompt)


func _on_lobby_message(_result, user, message, _type):
	var sender = Steam.getFriendPersonaName(user)
	Globals.display_message(chat_box, str(sender) + ": " + str(message))


func _on_lobby_update(_lobby_id, _changed_id, making_change_id, chat_state):
	var changer = Steam.getFriendPersonaName(making_change_id)
	if chat_state == 1:
		Globals.display_message(chat_box, str(changer) + " has joined the lobby")
		Globals.lobby_enemy_id = making_change_id
	elif chat_state == 2:
		Globals.display_message(chat_box, str(changer) + " has left the lobby")
		Globals.lobby_enemy_id = 0
	elif chat_state == 8:
		Globals.display_message(chat_box, str(changer) + " has been kicked from the lobby")
		Globals.lobby_enemy_id = 0
	elif chat_state == 16:
		Globals.display_message(chat_box, str(changer) + " has been banned from the lobby")
		Globals.lobby_enemy_id = 0
	else:
		Globals.display_message(chat_box, str(changer) + " did ... something")


func _on_p2p_session_request(remote_id):
	print("Session request")
	Steam.acceptP2PSessionWithUser(remote_id)
	Globals.make_p2p_handshake()


func _on_p2p_session_connect_fail(lobby_id, session_error):
	if session_error == 0:
		Globals.display_message(
			chat_box, "WARNING: Session failure with " + str(lobby_id) + " [no error given]."
		)
	elif session_error == 1:
		Globals.display_message(
			chat_box,
			(
				"WARNING: Session failure with "
				+ str(lobby_id)
				+ " [target user not running the same game]."
			)
		)
	elif session_error == 2:
		Globals.display_message(
			chat_box,
			(
				"WARNING: Session failure with "
				+ str(lobby_id)
				+ " [local user does not own app / game]."
			)
		)
	elif session_error == 3:
		Globals.display_message(
			chat_box,
			(
				"WARNING: Session failure with "
				+ str(lobby_id)
				+ " [target user is not connected to Steam]."
			)
		)
	elif session_error == 4:
		Globals.display_message(
			chat_box, "WARNING: Session failure with " + str(lobby_id) + " [connection timed out]."
		)
	elif session_error == 5:
		Globals.display_message(
			chat_box, "WARNING: Session failure with " + str(lobby_id) + " [unused]."
		)
	else:
		Globals.display_message(
			chat_box,
			(
				"WARNING: Session failure with "
				+ str(lobby_id)
				+ " [unknown error "
				+ str(session_error)
				+ "]."
			)
		)


func _on_copy_pressed():
	OS.set_clipboard(str(Globals.lobby_id))


func _on_leave_pressed():
	Globals.toggle_prompt(leave_prompt)


func _on_leave_confirm_pressed():
	Globals.go_back()
	Globals.leave_lobby()


func _on_leave_cancel_pressed():
	Globals.toggle_prompt(leave_prompt)


func _on_send_pressed():
	Globals.send_message(chat_box, message_box)


func _on_start_pressed():
	if Globals.lobby_enemy_id != 0:
		# Only start if both players are there
		print(Globals.lobby_enemy_id)
		Globals.go_main(true)
	else:
		# Otherwise, print an error in chat
		Globals.display_message(chat_box, "Both players must be here to start")


func _on_text_entered(_text):
	Globals.send_message(chat_box, message_box)
