extends Node

const USERDATA = "user://user_data.json"

const USERDEFAULTS = {
	"mouse_sensitivity": 75.0,
	"user_name": "Unnamed",
	"video_fov": 70.0,
	"video_fps": 60,
	"video_fullscreen": false
}

var user_data : Dictionary = {}

func _ready():
	get_data()

func get_data():
	var file = File.new()
	if not file.file_exists(USERDATA):
		user_data = USERDEFAULTS
		save_data()
	file.open(USERDATA, File.READ)
	var data = parse_json(file.get_as_text())
	user_data = data
	if user_data.size() != USERDEFAULTS.size():
		Logger.out([Logger.get_prefix("Game", "Warning"), "Your save data has been reset because it was outdated."])
		user_data = USERDEFAULTS
		save_data()
	file.close()
	Video.initialize()

func save_data():
	var file = File.new()
	file.open(USERDATA, File.WRITE)
	file.store_line(to_json(user_data))
	Video.initialize()
