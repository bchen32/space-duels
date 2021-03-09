extends Spatial

onready var join_button = $UI/VBoxContainer/HBoxContainer/VBoxContainer/Join
onready var create_button = $UI/VBoxContainer/HBoxContainer/VBoxContainer/Create
onready var quit_button = $UI/VBoxContainer/HBoxContainer/VBoxContainer/Quit
onready var quit_prompt = $UI/QuitPrompt
onready var quit_confirm = $UI/QuitPrompt/VBoxContainer/HBoxContainer/Quit
onready var quit_cancel = $UI/QuitPrompt/VBoxContainer/HBoxContainer/Cancel


export var join_scene_path = 'res://Scenes/RunnableScenes/JoinMenu.tscn'
export var create_scene_path = 'res://Scenes/RunnableScenes/CreateMenu.tscn'

func _ready():
	join_button.connect('pressed', self, '_on_join_pressed')
	create_button.connect('pressed', self, '_on_create_pressed')
	quit_button.connect('pressed', self, '_on_quit_pressed')
	quit_confirm.connect('pressed', self, '_on_quit_confirm_pressed')
	quit_cancel.connect('pressed', self, '_on_quit_cancel_pressed')

func _input(event):
	if event.is_action_released('ui_cancel'):
		toggle_quit_prompt()

func toggle_quit_prompt():
	if !quit_prompt.visible:
		quit_prompt.popup()
	else:
		quit_prompt.hide()

func _on_join_pressed():
	print('Join')
	get_tree().change_scene(join_scene_path)

func _on_create_pressed():
	print('Create')
	get_tree().change_scene(create_scene_path)

func _on_quit_pressed():
	toggle_quit_prompt()

func _on_quit_confirm_pressed():
	get_tree().quit()

func _on_quit_cancel_pressed():
	quit_prompt.hide()
