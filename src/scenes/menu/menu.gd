extends Control

onready var join_menu = $CenterContainer/JoinContainer
	
func _ready():
	$Container/Version.text = "v"+Game.version

func _on_Host_pressed():
	var server_incept_patch = true # harvey298 - incase anyone wants to have some fun :)
	
	if server_incept_patch == true:
		if get_tree().is_network_server() == true: # harvey298 - prevent server inception - could create a bug later
			print("Found Server already active, not proceeding")
			return
	Game.spawn_map(0)
	Game.spawn_controller("1", 0)
	Game.toggle_menu()
	Net.create_server()

func _on_Join_pressed():
	if join_menu.visible == false:
		join_menu.visible = true
	elif join_menu.visible == true:
		join_menu.visible = false

func _on_Connect_pressed():
	var address : String
	var port : int
	if $CenterContainer/JoinContainer/Panel/VBoxContainer/AddressContainer/Address.text != "":
		address = $CenterContainer/JoinContainer/Panel/VBoxContainer/AddressContainer/Address.text
	else:
		address = "127.0.0.1"
	if $CenterContainer/JoinContainer/Panel/VBoxContainer/PortContainer/Port.text != "":
		port = int($CenterContainer/JoinContainer/Panel/VBoxContainer/PortContainer/Port.text)
	else:
		port = Net.PORT
	Net.create_client(address, port)
	join_menu.visible = false
	Game.toggle_menu()

func _on_Quit_pressed():
	get_tree().quit()
