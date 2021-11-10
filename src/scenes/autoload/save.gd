extends Node

const USERDATA = "user://user_data.json"

const USERDEFAULTS = {
	"mouse": {
		"sensitivity": 75.0
	}, "user": {
		"username": "Unnamed"	
	}, "video": {
		"fullscreen": false
	}
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
	if user_data.keys() != USERDEFAULTS.keys():
		user_data = USERDEFAULTS
		save_data()
	file.close()

func save_data():
	var file = File.new()
	file.open(USERDATA, File.WRITE)
	file.store_line(to_json(user_data))
