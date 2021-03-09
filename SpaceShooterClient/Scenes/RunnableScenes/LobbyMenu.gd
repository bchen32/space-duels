extends Spatial

onready var back_button = $UI/VBoxContainer/Back

func _ready():
#	steam
#	buttons
	back_button.connect('pressed', self, '_on_back_pressed')

func _input(event):
	if event.is_action_released('ui_cancel'):
		Globals.go_back()

func _on_back_pressed():
	Globals.go_back()
