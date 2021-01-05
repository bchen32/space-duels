extends Node

var main = preload('res://Scenes/MainScenes/Main.tscn')

func _ready():
	var main_instance = main.instance()
	add_child(main_instance)
