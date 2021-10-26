extends Node

const PORT : int = 3524
const MAX_PLAYERS : int = 12
const HOST_RATE : float = 1.0/20.0
const PEER_RATE : float = 1.0/60.0

#func _physics_process(delta):
	#if is_instance_valid(Game.player):

func is_server():
	return get_tree().is_network_server()

func create_client(address : String, port : int):
	var _peer_connected = get_tree().connect("network_peer_connected", self, "_on_peer_connected")
	var _peer_disconnected = get_tree().connect("network_peer_disconnected", self, "_on_peer_disconnected")
	var _connected_to_server = get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	var _connection_failed = get_tree().connect("connection_failed", self, "_on_connection_failed")
	var _server_disconnected = get_tree().connect("server_disconnected", self, "_on_server_disconnected")
	var network = NetworkedMultiplayerENet.new()
	if get_tree().is_network_server() == true: # harvey298 - prevent joining to self - could create a bug later
		print("Found Server, not joining")
		return
	network.create_client(address, port)
	get_tree().set_network_peer(network)
	print("Client created")

func create_server():
	var _peer_connected = get_tree().connect("network_peer_connected", self, "_on_peer_connected")
	var _peer_disconnected = get_tree().connect("network_peer_disconnected", self, "_on_peer_disconnected")
	var network = NetworkedMultiplayerENet.new()
	network.create_server(PORT, MAX_PLAYERS)
	get_tree().set_network_peer(network)
	print("Server created")

func _on_peer_connected(id):
	Game.spawn_controller(str(id), 1)
	print("Peer connected")

func _on_peer_disconnected(id):
	print("Peer disconnected!")

func _on_connected_to_server():
	print("Connected to server")
	var id = get_tree().get_network_unique_id()
	Game.menu.visible = false
	Game.spawn_map(0)
	Game.spawn_controller(str(id), 0)
	

func _on_connection_failed():
	print("Connection to server failed")
