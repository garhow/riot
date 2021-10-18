extends Position3D

export var camera_acceleration = 12
export var camera_sensitivity = 0.2

var camrot_h = 0
var camrot_v = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		camrot_h += -event.relative.x * camera_sensitivity
		camrot_v += -event.relative.y * camera_sensitivity

func _physics_process(delta):
	rotation_degrees.x = lerp(rotation_degrees.x, camrot_v, delta * camera_acceleration)
	rotation_degrees.y = lerp(rotation_degrees.y, camrot_h, delta * camera_acceleration)
