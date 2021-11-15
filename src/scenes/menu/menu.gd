extends Control

onready var settings = get_node("Center/Settings/Tabs")

func _ready():
	$Container/Version.text = "v"+Game.version
	for resolution in Video.RESOLUTIONS:
		if resolution.x <= OS.get_screen_size().x and resolution.y <= OS.get_screen_size().y:
			Game.menu.get_node("Center/Settings/Tabs/Video/Resolution/Options").add_item(str(resolution.x) + "×" + str(resolution.y))
	load_settings()

func _process(_delta):
	network_check()

##
# Host
##

func _on_Host_pressed():
	var map = Game.maps.keys()[randi() % Game.maps.keys().size()]
	Game.spawn_map(map)
	Game.spawn_controller(1, 0)
	Game.toggle_menu()
	Net.create_server(Net.PORT, Net.MAX_PLAYERS, map)

##
# Join
##

func _on_Join_pressed():
	hide_all_submenus()
	toggle_menu($Center/Join)

func _on_Connect_pressed():
	var address : String
	var port : int
	if $Center/Join/Panel/VBox/Address/Input.text != "":
		address = $Center/Join/Panel/VBox/Address/Input.text
	else:
		address = "127.0.0.1"
	if $Center/Join/Panel/VBox/Port/Input.text != "":
		port = int($Center/Join/Panel/VBox/Port/Input.text)
	else:
		port = Net.PORT
	Net.create_client(address, port)
	hide_all_submenus()
	$Center/Connecting.visible = true

func _on_Cancel_Connection_pressed():
	if Net.connected_to_server == false:
		get_tree().network_peer = null
		Net.network.close_connection()
	else:
		Net.server_disconnect()
	$Center/Connecting.visible = false

##
# Disconnect
##

func _on_Disconnect_pressed():
	Net.server_disconnect()

##
# Settings
##

func _on_Settings_pressed():
	hide_all_submenus()
	toggle_menu($Center/Settings)

func _on_SaveChanges_pressed():
	Save.user_data = {
		"mouse_sensitivity": settings.get_node("Mouse/Sensitivity/Slider").value,
		"user_name": settings.get_node("User/Username/Input").text,
		"video_fov": settings.get_node("Video/FOV/Input").value,
		"video_fps": settings.get_node("Video/FPS/Input").value,
		"video_mode": settings.get_node("Video/Mode/Options").selected,
		"video_resolution": settings.get_node("Video/Resolution/Options").selected
	}
	Save.save_data()
	
func load_settings():
	# Mouse
	settings.get_node("Mouse/Sensitivity/Slider").value = Save.user_data.get("mouse_sensitivity")
	# User
	settings.get_node("User/Username/Input").text = Save.user_data.get("user_name") # Username
	# Video
	settings.get_node("Video/FOV/Input").value = Save.user_data.get("video_fov") # Field of View
	settings.get_node("Video/FPS/Input").value = Save.user_data.get("video_fps") # FPS limit
	settings.get_node("Video/Mode/Options").selected = Save.user_data.get("video_mode") # Mode
	settings.get_node("Video/Resolution/Options").selected = Save.user_data.get("video_resolution") # Resolution

##
# Credits
##

func _on_Credits_pressed():
	hide_all_submenus()
	toggle_menu($Center/Credits)
		
func _on_Credits_Close_pressed():
	$Center/Credits.visible = false

##
# Quit
##

func _on_Quit_pressed():
	get_tree().quit()

func hide_all_submenus():
	for submenu in get_tree().get_nodes_in_group("submenu"):
		submenu.visible = false

func toggle_menu(control):
	if control.visible == false:
		control.visible = true
	elif control.visible == true:
		control.visible = false

func network_check():
	if Net.connected_to_server == true:
		$Background.color = Color8(55, 0, 0, 125)
		$Container/VBox/VBox/Host.visible = false
		$Container/VBox/VBox/Join.visible = false
		$Container/VBox/VBox/Disconnect.visible = true
	elif Net.connected_to_server == false:
		$Background.color = Color8(55, 0, 0, 255)
		$Container/VBox/VBox/Host.visible = true
		$Container/VBox/VBox/Join.visible = true
		$Container/VBox/VBox/Disconnect.visible = false
