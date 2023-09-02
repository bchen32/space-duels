extends Spatial

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _physics_process(_delta):
	if Input.is_action_pressed('ui_up'):
		$Player.camera.current = true
	if Input.is_action_pressed('ui_down'):
		$OutCam.current = true
	if Input.is_action_just_pressed('ui_cancel'):
		get_tree().reload_current_scene()