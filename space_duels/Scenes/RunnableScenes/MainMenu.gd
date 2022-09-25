extends Spatial

onready var join_button = $UI/Column/Row/Column/Join
onready var create_button = $UI/Column/Row/Column/Create
onready var quit_button = $UI/Column/Row/Column/Quit

onready var quit_prompt = $UI/QuitPrompt
onready var quit_confirm = $UI/QuitPrompt/Column/Row/Confirm
onready var quit_cancel = $UI/QuitPrompt/Column/Row/Cancel

export var join_scene_path = "res://Scenes/RunnableScenes/JoinMenu.tscn"
export var create_scene_path = "res://Scenes/RunnableScenes/CreateMenu.tscn"


func _ready():
	# Buttons
	join_button.connect("pressed", self, "_on_join_pressed")
	create_button.connect("pressed", self, "_on_create_pressed")
	quit_button.connect("pressed", self, "_on_quit_pressed")
	quit_confirm.connect("pressed", self, "_on_quit_confirm_pressed")
	quit_cancel.connect("pressed", self, "_on_quit_cancel_pressed")


func _input(event):
	if event.is_action_released("ui_cancel"):
		Globals.toggle_prompt(quit_prompt)


func _on_join_pressed():
	print("Join")
	get_tree().change_scene(join_scene_path)


func _on_create_pressed():
	print("Create")
	get_tree().change_scene(create_scene_path)


func _on_quit_pressed():
	Globals.toggle_prompt(quit_prompt)


func _on_quit_confirm_pressed():
	get_tree().quit()


func _on_quit_cancel_pressed():
	Globals.toggle_prompt(quit_prompt)
