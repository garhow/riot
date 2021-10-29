extends Control
	
func _ready():
	$Container/Version.text = "v"+Game.version

func _process(_delta):
	network_check()

##
# Host
##

func _on_Host_pressed():
	var server_incept_patch = true # harvey298 - incase anyone wants to have some fun :)
	
	if server_incept_patch == true and get_tree().network_peer != null and get_tree().is_network_server(): # harvey298 - prevent server inception - could create a bug later
			print("Already connected to a server, not proceeding.")
			return
	Game.spawn_map(0)
	Game.spawn_controller("1", 0)
	Game.toggle_menu()
	Net.create_server(Net.PORT)

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
	$Center/Join.visible = false

##
# Disconnect
##

func _on_Disconnect_pressed():
	Net.server_disconnect()

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
	if Net.is_connected_to_server():
		$Container/VBox/VBox/Host.visible = false
		$Container/VBox/VBox/Join.visible = false
		$Container/VBox/VBox/Disconnect.visible = true
	else:
		$Container/VBox/VBox/Host.visible = true
		$Container/VBox/VBox/Join.visible = true
		$Container/VBox/VBox/Disconnect.visible = false
