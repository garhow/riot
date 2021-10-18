extends KinematicBody

export var acceleration = 2
export var camera_acceleration = 12
export var camera_sensitivity = 0.2
export var gravity = 18
export var jump_speed = 10
export var max_speed = 12

var direction : Vector3
var speed : float
var target : Vector3
var velocity : Vector3

func _physics_process(delta):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += jump_speed
	
	velocity.y += -gravity * delta
	velocity = lerp(velocity, direction * max_speed, acceleration * delta)
	velocity = move_and_slide(velocity, Vector3.UP)
