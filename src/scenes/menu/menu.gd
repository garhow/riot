extends Control

onready var join_menu = $Center/Join
onready var credits_menu = $Center/Credits
	
func _ready():
	$Container/Version.text = "v"+Game.version

##
# Host
##

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

##
# Join
##

func _on_Join_pressed():
	if join_menu.visible == false:
		join_menu.visible = true
	elif join_menu.visible == true:
		join_menu.visible = false

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
	join_menu.visible = false
	Game.toggle_menu()

##
# Credits
##

func _on_Credits_pressed():
	if credits_menu.visible == false:
		credits_menu.visible = true
	elif credits_menu.visible == true:
		credits_menu.visible = false
		
func _on_Credits_Close_pressed():
	credits_menu.visible = false

##
# Quit
##

func _on_Quit_pressed():
	get_tree().quit()
