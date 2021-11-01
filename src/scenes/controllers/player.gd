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

var selected_weapon : int = 1

##
# Nodes
##

onready var body = $Body
onready var camera = $Body/Head/Camroot/Camera # Camera
onready var camroot = $Body/Head/Camroot # Camera Root
onready var head = $Body/Head # Player head
onready var weaponroot = $Body/Head/Weaponroot # Weapon Root

# Raycasts
onready var headcast = $Body/Headcast
onready var footcast = $Body/Footcast
onready var ribcast = $Body/Ribcast

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
	
	if event is InputEventMouseButton and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and event.is_pressed():
		if event.button_index == BUTTON_WHEEL_UP or event.button_index == BUTTON_WHEEL_DOWN:
			if event.button_index == BUTTON_WHEEL_UP:
				if selected_weapon < weaponroot.get_child_count():
					selected_weapon += 1
				else:
					selected_weapon = 1
			elif event.button_index == BUTTON_WHEEL_DOWN:
				if selected_weapon > 1:
					selected_weapon -= 1
				else:
					selected_weapon = weaponroot.get_child_count()
		for weapon in weaponroot.get_children():
			weapon.visible = false
			weaponroot.get_node(str(selected_weapon)).visible = true

func _physics_process(delta):
	if not $Body.is_on_floor():
		fall.y -= delta * gravity
	if Input.is_action_pressed("jump") and $Body.is_on_wall() and not headcast.is_colliding():
		if footcast.is_colliding() and ribcast.is_colliding():
			fall.y = climb_speed
	process_motion(delta)
	process_weapons()
	direction = Vector3()
	$Body.move_and_slide(fall, Vector3.UP)

func process_motion(delta):
	var direction_bf = (Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")) * $Body.global_transform.basis.z
	var direction_rl = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) * $Body.global_transform.basis.x
	
	direction += direction_bf + direction_rl
	#Net.update_player_local(direction_bf, direction_rl)
	
	if Input.is_action_just_pressed("jump") and $Body.is_on_floor():
			fall.y = jump_speed
	
	speed = sprint_speed
	if Input.is_action_pressed("sneak") and $Body.is_on_floor():
		speed = sneak_speed
	if Input.is_action_pressed("crouch"):
		$Body/Collision.shape.height -= crouch_acceleration * delta
		if $Body.is_on_floor():
			speed = crouch_speed
	else:
		$Body/Collision.shape.height += crouch_acceleration * delta
	
	$Body/Collision.shape.height = clamp($Body/Collision.shape.height, crouch_height, default_height)

	direction = direction.normalized()
	horizontal_velocity = horizontal_velocity.linear_interpolate(direction * speed, acceleration * delta)
	movement.x = horizontal_velocity.x
	movement.z = horizontal_velocity.z
	$Body.move_and_slide(movement, Vector3.UP)

func process_weapons():
	if weaponroot.get_child_count() > 0:
		if Input.is_action_just_pressed("fire"):
			weaponroot.get_node(str(selected_weapon)).primary()
	else:
		var knife = load("res://scenes/weapons/knife.tscn").instance()
		var shotgun = load("res://scenes/weapons/shotgun.tscn").instance()
		knife.name = "1"
		shotgun.name = "2"
		weaponroot.add_child(knife)
		weaponroot.add_child(shotgun)
		for weapon in weaponroot.get_children():
			weapon.visible = false
		weaponroot.get_node(str(selected_weapon)).visible = true
		
