extends Node

var player

var version = ProjectSettings.get_setting("application/config/version")

onready var main = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
onready var menu = main.get_node("Menu")

onready var controllers = [
	preload("res://scenes/controllers/player.tscn"),
	preload("res://scenes/controllers/peer.tscn")
]

onready var maps = [
	preload("res://scenes/maps/test_level.tscn")
]

func _ready():
	randomize()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel") and Net.is_server():
		toggle_menu()

func spawn_map(map_id : int):
	var map = maps[map_id].instance()
	main.add_child(map)

func spawn_controller(name : String, type: int):
	var controller = controllers[type].instance()
	controller.name = name
	main.add_child(controller)
	controller.get_node("Body").global_transform = get_spawn()

func get_spawn():
	var spawns = main.get_node_or_null("Map/Spawns")
	if spawns:
		return spawns.get_child(randi() % spawns.get_child_count()).global_transform
	else:
		return Transform(Basis.IDENTITY, Vector3(0.0, 10.0 + randf(), 0.0))

func toggle_menu():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		menu.visible = true
		#menu.get_node("Background").visible = true
		#menu.get_node("Container").visible = true
	elif Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		menu.visible = false
		#menu.get_node("Background").visible = false
		#menu.get_node("Container").visible = false
