extends Node
class_name Player

##
# Player configuration
##

export var acceleration = 6
export var climb_speed = 6.8
export var crouch_acceleration = 6.2
export var crouch_height = 0.6
export var crouch_speed = 1.5
export var default_height = 1.7
export var gravity = 16.2
export var jump_speed = 6.4
export var max_health = 100
export var sprint_speed = 5
export var sneak_speed = 2

export var mouse_acceleration = 18
export var mouse_sensitivity = 0.1

var climb : bool
var dead : bool = false
var direction : Vector3
var fall : Vector3
var horizontal_velocity : Vector3
var movement : Vector3
var speed : float
var velocity : Vector3

var health : float = max_health

##
# Nodes
##

onready var body = $Body
onready var head = $Body/Head # Player head
onready var footcast = $Body/Footcast
onready var headcast = $Body/Headcast
onready var ribcast = $Body/Ribcast
onready var camroot = $Body/Head/Camroot
onready var camera = $Body/Head/Camroot/Camera # First-person camera
onready var camera_animation = $Body/Head/Camroot/Camera/Animation # First-person camera animation player

##
# Functions
##

func _ready():
	Game.player = self

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		$Body.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))

func _physics_process(delta):
	if not $Body.is_on_floor():
		fall.y -= delta * gravity
	if Input.is_action_pressed("jump") and $Body.is_on_wall() and not headcast.is_colliding():
		if footcast.is_colliding() and ribcast.is_colliding():
			fall.y = climb_speed
	process_input(delta)
	process_motion(delta)
	direction = Vector3()
	$Body.move_and_slide(fall, Vector3.UP)

func process_input(delta):
	direction += (Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")) * $Body.global_transform.basis.z
	direction += (Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) * $Body.global_transform.basis.x
	
	if Input.is_action_just_pressed("jump") and $Body.is_on_floor():
			fall.y = jump_speed
	
	if Input.is_action_pressed("sneak"):
		speed = sneak_speed
	if Input.is_action_pressed("crouch"):
		$Body/Collision.shape.height -= crouch_acceleration * delta
		speed = crouch_speed
	else:
		$Body/Collision.shape.height += crouch_acceleration * delta
	
	$Body/Collision.shape.height = clamp($Body/Collision.shape.height, crouch_height, default_height)

func process_motion(delta):
	direction = direction.normalized()
	speed = sprint_speed
	horizontal_velocity = horizontal_velocity.linear_interpolate(direction * speed, acceleration * delta)
	movement.x = horizontal_velocity.x
	movement.z = horizontal_velocity.z
	$Body.move_and_slide(movement, Vector3.UP)
