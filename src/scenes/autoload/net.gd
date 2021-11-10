extends Node

const PORT : int = 3524
const MAX_PLAYERS : int = 12
const HOST_RATE : float = 1.0/20.0
const PEER_RATE : float = 1.0/60.0
var network : NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
var connected_to_server : bool = false

# Client-side data
var player_data : Dictionary = {}
var server_data : Dictionary = {}

# Server-side data
var map_name : String

##
# Functions
##

func _physics_process(_delta): # Run once for each frame
	if is_instance_valid(Game.player) and get_tree().network_peer:
		if get_tree().is_network_server():
			var world_state = [[]]
			for body in get_tree().get_nodes_in_group("players"):
				world_state[0].push_back([body.name, body.translation, body.rotation.y, body.get_node("Head").rotation.x, body.velocity, body.is_on_floor()])
			rpc_unreliable("update_world", world_state)
		else:
			rpc_unreliable_id(1, "update_peer", Game.player.translation, Game.player.rotation.y, Game.player.get_node("Head").rotation.x, Game.player.velocity)

func get_player_data(): # Returns local player data
	return {name=Save.user_data.get("user").get("username")}

func server_disconnect(): # Attempts to gracefully close a server or disconnect from a server
	if get_tree().get_network_unique_id() == 1:
		Logger.out([Logger.get_prefix("Networking", "Info"), "Closing server."])
	else:
		Logger.out([Logger.get_prefix("Networking", "Info"), "Disconnecting from server."])
		get_tree().disconnect("connected_to_server", self, "_on_connected_to_server")
		get_tree().disconnect("connection_failed", self, "_on_connection_failed")
		get_tree().disconnect("server_disconnected", self, "_on_server_disconnected")
	get_tree().disconnect("network_peer_connected", self, "_on_peer_connected")
	get_tree().disconnect("network_peer_disconnected", self, "_on_peer_disconnected")
	for player in get_tree().get_network_connected_peers():
		Game.remove_controller(player)
	Game.remove_map()
	Game.remove_controller(get_tree().get_network_unique_id())
	player_data = {}
	connected_to_server = false
	get_tree().network_peer = null
	network.close_connection()
	Game.menu.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

####
## Client networking functions
####

func create_client(address : String, port : int): # Connects to a server
	get_tree().connect("network_peer_connected", self, "_on_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_peer_disconnected")
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	get_tree().connect("connection_failed", self, "_on_connection_failed")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")
	network.create_client(address, port)
	get_tree().set_network_peer(network)
	Logger.out([Logger.get_prefix("Networking", "Info"), "Now connecting to ", address, ":", str(port), "!"])

remote func update_peer(t : Vector3, ry : float, hrx : float , v : Vector3): # Updates a peer node with information given by the server
	var peer = Game.main.get_node(str(get_tree().get_rpc_sender_id()))
	peer.translation = t
	peer.rotation.y = ry
	peer.get_node("Head").rotation.x = hrx
	peer.velocity = v

remote func apply_player_data(): # Applies player data given to by the server
	for id in player_data.keys():
		if id != get_tree().get_network_unique_id():
			Game.main.get_node(str(id)).get_node("Nametag/Viewport/Panel/Label").text = player_data[id].get("name")

remote func confirm_handshake(data): # Loads given server data
	server_data = data
	connected_to_server = true
	_on_handshake()

####
## Server networking functions
####

func create_server(port : int, max_players : int, map : String):
	get_tree().connect("network_peer_connected", self, "_on_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_peer_disconnected")
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	connected_to_server = true
	player_data[1] = get_player_data()
	map_name = map
	Logger.out([Logger.get_prefix("Networking", "Info"), "Now hosting a server on port ", str(port), "!"])

puppet func update_world(world_state : Array):
	for player in world_state[0]:
		if int(player[0]) == get_tree().get_network_unique_id():
			continue
		Game.main.get_node(player[0]).update(player[1], player[2], player[3], player[4])

remote func register_player_data(data):
	player_data[get_tree().get_rpc_sender_id()] = data
	rpc_id(get_tree().get_rpc_sender_id(), "apply_player_data")

func get_server_data(): # Returns server data
	return {map=map_name}

##
# Events
##

func _on_peer_connected(id):
	Logger.out([Logger.get_prefix("Networking", "Info"), str(id), " has connected to the server!"])
	rpc_id(id, "register_player_data", get_player_data())
	if get_tree().get_network_unique_id() == 1:
		rpc_id(id, "confirm_handshake", get_server_data())
	Game.spawn_controller(id, 1)

func _on_peer_disconnected(id):
	Logger.out([Logger.get_prefix("Networking", "Info"), str(id), " has disconnected."])
	player_data.erase(id)
	Game.remove_controller(id)

func _on_connected_to_server():
	Logger.out([Logger.get_prefix("Networking", "Info"), "Established a connection with server."])

func _on_handshake():
	Logger.out([Logger.get_prefix("Networking", "Info"), "Shook hands with server. Now loading server data."])
	Game.spawn_map(server_data["map"])
	Game.spawn_controller(get_tree().get_network_unique_id(), 0)
	Game.toggle_menu()
	Game.menu.get_node("Center/Connecting").visible = false

func _on_connection_failed():
	Logger.out([Logger.get_prefix("Networking", "Info"), "Connection to the server failed!"])

func _on_server_disconnected():
	Logger.out([Logger.get_prefix("Networking", "Info"), "You have lost connection to the server."])
	server_disconnect()
