extends KinematicBody

##
# Configuration variables
##

# Movement configuration
export var acceleration = 6
export var climb_speed = 6.8
export var gravity = 12.8
export var jump_speed = 5.4
export var sprint_speed = 5
export var walk_speed = 2

# Mouse configuration
export var mouse_acceleration = 18
export var mouse_sensitivity = 0.1

##
# Physics variables
##

var climb : bool
var direction : Vector3
var fall : Vector3
var horizontal_velocity : Vector3
var movement : Vector3
var speed : float
var target : Vector3
var velocity : Vector3

##
# Node variables
##

# Generic nodes
onready var head = $Head # Player head

# Raycast nodes
onready var groundcast = $Groundcast 
onready var footcast = $Footcast
onready var headcast = $Headcast
onready var ribcast = $Ribcast

# Camera-related nodes
onready var camroot = $Head/Camroot
onready var fpscamera = $Head/Camroot/Camera # First-person camera
onready var tpscamera = $Head/Camroot/TPSCamera # Third-person camera
onready var camera_animation = $Head/Camroot/Camera/Animation # First-person camera animation player

##
# Camera toggles
##

func camera_toggle():
	if Input.is_action_just_pressed("camera_mode"):
		if fpscamera.current == true:
			fpscamera.current = false
			tpscamera.current = true
		else:
			fpscamera.current = true
			tpscamera.current = false

func mouse_toggle():
	if Input.is_action_just_pressed("ui_cancel") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.is_action_just_pressed("ui_cancel") and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

##
# Raycast collision checks
##

func climb_check():
	if is_on_wall() and footcast.is_colliding() and not headcast.is_colliding() and ribcast.is_colliding():
		climb = true
	else:
		climb = false

##
# Movement input and velocity
##

func player_movements():
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x / 2
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x / 2
	if Input.is_action_pressed("walk"):
		speed = walk_speed
	if Input.is_action_just_pressed("jump") and is_on_floor():
		fall.y = jump_speed

func wall_climb():
	if Input.is_action_pressed("jump") and not is_on_floor() and climb == true:
		fall.y = climb_speed

##
# Event functions
##

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))

func _physics_process(delta):
	# Initialize direction
	direction = Vector3()
	
	# Set default speed
	speed = sprint_speed
	
	# Camera toggles
	mouse_toggle()
	camera_toggle()
	
	# Raycast collision checks
	climb_check()
	
	# Climb up walls
	wall_climb()
	
	# Enforce gravity
	move_and_slide(fall, Vector3.UP)
	if not is_on_floor():
		fall.y -= delta * gravity
	
	# Player movement
	player_movements()
	
	# Normalize direction after movement is processed
	direction = direction.normalized()
	
	horizontal_velocity = horizontal_velocity.linear_interpolate(direction * speed, acceleration * delta)
	movement.x = horizontal_velocity.x
	movement.z = horizontal_velocity.z
	move_and_slide(movement, Vector3.UP)
