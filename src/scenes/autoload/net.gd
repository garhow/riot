extends Node

const PORT : int = 3524
const MAX_PLAYERS : int = 12
const HOST_RATE : float = 1.0/20.0
const PEER_RATE : float = 1.0/60.0

##
# Functions
##

func is_connected_to_server():
	if get_tree().network_peer == null:
		return false
	else:
		return true

func create_client(address : String, port : int):
	var _peer_connected = get_tree().connect("network_peer_connected", self, "_on_peer_connected")
	var _peer_disconnected = get_tree().connect("network_peer_disconnected", self, "_on_peer_disconnected")
	var _connected_to_server = get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	var _connection_failed = get_tree().connect("connection_failed", self, "_on_connection_failed")
	var _server_disconnected = get_tree().connect("server_disconnected", self, "_on_server_disconnected")
	var network = NetworkedMultiplayerENet.new()
	network.create_client(address, port)
	get_tree().set_network_peer(network)
	print(Log.get_prefix("Networking", "Info"), "Now connecting to ", address, ":", str(port), "!")

func create_server(port : int):
	var _peer_connected = get_tree().connect("network_peer_connected", self, "_on_peer_connected")
	var _peer_disconnected = get_tree().connect("network_peer_disconnected", self, "_on_peer_disconnected")
	var network = NetworkedMultiplayerENet.new()
	network.create_server(port, MAX_PLAYERS)
	get_tree().set_network_peer(network)
	print(Log.get_prefix("Networking", "Info"), "Now hosting a new server on port ", str(port), "!")

func server_disconnect():
	if get_tree().get_network_unique_id() == 1:
		print(Log.get_prefix("Networking", "Info"), "Closing server.")
	else:
		print(Log.get_prefix("Networking", "Info"), "Disconnecting from server.")
		get_tree().disconnect("connected_to_server", self, "_on_connected_to_server")
		get_tree().disconnect("connection_failed", self, "_on_connection_failed")
		get_tree().disconnect("server_disconnected", self, "_on_server_disconnected")
	Game.remove_map()
	Game.remove_controller(get_tree().get_network_unique_id())
	get_tree().disconnect("network_peer_connected", self, "_on_peer_connected")
	get_tree().disconnect("network_peer_disconnected", self, "_on_peer_disconnected")
	get_tree().network_peer = null
	Game.menu.visible = true

##
# Events
##

func _on_peer_connected(id):
	Game.spawn_controller(str(id), 1)
	print(Log.get_prefix("Networking", "Info"), str(id), " has connected to the server!")
	
func _on_peer_disconnected(id):
	print(Log.get_prefix("Networking", "Info"), str(id), " has disconnected.")

func _on_connected_to_server():
	print(Log.get_prefix("Networking", "Info"), "Now connected to a server.")
	var id = get_tree().get_network_unique_id()
	Game.spawn_map(0)
	Game.spawn_controller(str(id), 0)
	Game.toggle_menu()
	

func _on_connection_failed():
	print(Log.get_prefix("Networking", "Info"), "Connection to the server failed!")
