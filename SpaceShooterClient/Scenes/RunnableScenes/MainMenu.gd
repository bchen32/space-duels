extends Spatial

onready var join_button = $Menu/CenterRow/Buttons/Join
onready var create_button = $Menu/CenterRow/Buttons/Create
onready var quit_button = $Menu/CenterRow/Buttons/Quit
onready var fade = $Modulate/FadeOut

var scene_to_load

func _ready():
	join_button.connect('pressed', self, '_on_join_pressed')
	create_button.connect('pressed', self, '_on_create_pressed')
	quit_button.connect('pressed', self, '_on_quit_pressed')
	fade.connect('animation_finished', self, '_on_fade_finished')


func _on_join_pressed():
	fade.play('FadeOut')
	print('Join')

func _on_create_pressed():
	fade.play('FadeOut')
	print('Create')

func _on_quit_pressed():
	get_tree().quit()

func _on_fade_finished(_anim_name):
	print('Fade finished')
#	get_tree().change_scene(scene_to_load)
