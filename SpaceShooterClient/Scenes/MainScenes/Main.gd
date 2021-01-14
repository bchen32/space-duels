extends Spatial

func _ready():
	pass

func _physics_process(_delta):
	if Input.is_action_pressed('ui_up'):
		$Player/Camera.current = true
	if Input.is_action_pressed('ui_down'):
		$OutCam.current = true
	if Input.is_action_just_pressed('ui_cancel'):
		var _error = get_tree().reload_current_scene()
	if Input.is_action_just_pressed('quit'):
		get_tree().quit()
