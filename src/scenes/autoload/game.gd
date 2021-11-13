extends Node

var player : Player

var version = ProjectSettings.get_setting("application/config/version")
var protocol_version : int = ProjectSettings.get_setting("application/config/protocol_version")

onready var main = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
onready var menu = main.get_node("Menu")
onready var console = menu.get_node("Console")

var controllers = [
	preload("res://scenes/controllers/player.tscn"),
	preload("res://scenes/controllers/peer.tscn")
]

var maps : Dictionary = {
	"test_arena": load("res://scenes/maps/test/arena.tscn"),
	"test_classic": load("res://scenes/maps/test/classic.tscn"),
	"test_practice": load("res://scenes/maps/test/practice.tscn")
}

func _ready():
	Logger.out([Logger.get_prefix("game", "info"), "Welcome to Riot ", "v"+version, "!"])
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel") and Net.connected_to_server == true:
		toggle_menu()
	if Input.is_action_just_pressed("toggle_console"):
		toggle_console()

func spawn_map(map : String):
	main.add_child(maps[map].instance())

func spawn_controller(id : int, type: int):
	var controller = controllers[type].instance()
	controller.name = str(id)
	main.add_child(controller)
	controller.global_transform = get_spawn()

func remove_map():
	main.remove_child(main.get_node("Map"))

func remove_controller(id):
	main.get_node(str(id)).free()

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
	elif Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		menu.visible = false

func toggle_console():
	if console.visible == false:
		console.visible = true
	elif console.visible == true:
		console.visible = false
