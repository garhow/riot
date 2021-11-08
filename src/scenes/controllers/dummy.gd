extends KinematicBody
class_name Dummy

var health : int = 100
var timer = Timer.new()

func _ready():
	timer.wait_time = 3
	timer.connect("timeout", self, "_on_Regen")
	add_child(timer)

func _physics_process(_delta):
	if health <= 0:
		health = 0
		visible = false
		timer.start()

func _on_Regen():
	health = 100
	visible = true
	timer.stop()
