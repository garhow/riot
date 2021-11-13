extends KinematicBody
class_name Player

##
# Player configuration
##

# Input variables
var mouse_sensitivity = Save.user_data.get("mouse").get("sensitivity")
var camera_rotation : Vector2 = Vector2.ZERO
var movement_input : Vector2 = Vector2.ZERO

# Movement variables
const ACCELERATION : float = 12.0
const GRAVITY : float = 20.0
const JUMP_FORCE : float = 6.4
const sprint_speed : float = 5.0
const sneak_speed : float = 2.0
var direction : Vector3
var grounded : bool
var jumping : bool
var movement : Vector3
var speed : float
var velocity : Vector3

# Combat variables
const MAX_HEALTH : int = 100
var health : int = MAX_HEALTH
var selected_weapon : int = 1

# Local variables
const SWAY : float = 35.0

# Node variables
onready var head = get_node("Head")
onready var hud = get_node("Head/Camroot/Camera/HUD")
onready var weaponlocation = get_node("Head/WeaponLocation")
onready var weaponroot = get_node("Head/Hands")

##
# Functions
##

func _ready():
	Game.player = self
	weaponroot.set_as_toplevel(true)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		camera_rotation = Vector2(-event.relative.y * mouse_sensitivity * 0.001, -event.relative.x * mouse_sensitivity * 0.001)
	
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
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		process_input(delta)
	process_movement(delta)
	process_rotation(delta)
	process_combat()

func process_combat():
	if weaponroot.get_child_count() > 0:
		if Game.menu.visible == false:
			if Input.is_action_just_pressed("fire"):
				weaponroot.get_node(str(selected_weapon)).primary()
			elif Input.is_action_just_pressed("alt_fire"):
				weaponroot.get_node(str(selected_weapon)).secondary()
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

func process_input(delta : float):
	movement_input.x = int(Input.is_action_pressed("move_backward")) - int(Input.is_action_pressed("move_forward"))
	movement_input.y = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	
	speed = sprint_speed
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jumping = true
		health -= 10
	if Input.is_action_pressed("jump") and not is_on_floor() and is_on_wall() and $Ribcast.is_colliding() and not $Headcast.is_colliding():
		velocity.y = JUMP_FORCE
	if Input.is_action_pressed("sneak") and is_on_floor():
		speed = sneak_speed
	if Input.is_action_pressed("crouch"):
		$Collision.shape.height -= ACCELERATION * delta
		if is_on_floor():
			speed = sneak_speed
	else:
		$Collision.shape.height += ACCELERATION * delta
	$Collision.shape.height = clamp($Collision.shape.height, 0.75, 1.5)

func process_movement(delta : float):
	direction = movement_input.x * global_transform.basis.z + movement_input.y * global_transform.basis.x
	direction = direction.normalized()
	movement = movement.linear_interpolate(direction * speed, ACCELERATION * delta)
	
	if is_on_floor():
		ground_move(delta)
	elif not is_on_floor():
		air_move(delta)
	
	velocity.x = movement.x
	velocity.y += Vector3.DOWN.y * GRAVITY * delta
	velocity.z = movement.z
	velocity = move_and_slide(velocity, Vector3.UP, true)

func process_rotation(delta : float):
	$Head.rotate_x(deg2rad(camera_rotation.x))
	$Head.rotation.x = clamp($Head.rotation.x, deg2rad(-89), deg2rad(89))
	rotate_y(deg2rad(camera_rotation.y))
	weaponroot.global_transform.origin = weaponlocation.global_transform.origin
	weaponroot.rotation.x = lerp_angle(weaponroot.rotation.x, head.rotation.x, SWAY * delta)
	weaponroot.rotation.y = lerp_angle(weaponroot.rotation.y, rotation.y, SWAY * delta)
	camera_rotation = Vector2.ZERO

func air_move(_delta : float):
	grounded = false
	pass # Placeholder for air strafing and other things

func ground_move(_delta : float):
	if not grounded:
		var sound = AudioStreamPlayer3D.new()
		add_child(sound)
		sound.bus = "Sound Effects"
		sound.stream = load("res://sounds/player/walk"+str(floor(rand_range(1, 3)))+".mp3")
		sound.stream.loop = false
		sound.play()
	grounded = true
	if jumping:
		grounded = false
		jumping = false
		velocity.y = Vector3.UP.y * JUMP_FORCE
