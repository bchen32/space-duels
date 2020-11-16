extends Spatial

onready var fps_counter = get_node('FPS')

func _ready():
	pass

func _process(_delta):
	var fps = Engine.get_frames_per_second()
	fps_counter.text = str(fps)

func _physics_process(_delta):
	if Input.is_action_pressed('ui_up'):
		$Player/Camera.current = true
	if Input.is_action_pressed('ui_down'):
		$OutCam.current = true
