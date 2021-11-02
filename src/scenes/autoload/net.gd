extends Node

const PORT : int = 3524
const MAX_PLAYERS : int = 12
const HOST_RATE : float = 1.0/20.0
const PEER_RATE : float = 1.0/60.0
const VERSION : int = 004

var network : NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()

##
# Functions
##

func _physics_process(_delta):
	if is_instance_valid(Game.player) and get_tree().network_peer:
		if get_tree().is_network_server():
			var world_state = [[]]
			for body in get_tree().get_nodes_in_group("players"):
				world_state[0].push_back([body.owner.name, body.translation, body.rotation.y, body.get_node("Head").rotation.x, body.get_parent().velocity, body.is_on_floor()])
			rpc_unreliable("update_world", world_state)
		else:
			rpc_unreliable_id(1, "update_peer", Game.player.body.translation, Game.player.body.rotation.y, Game.player.head.rotation.x, Game.player.velocity)

func is_connected_to_server():
	if get_tree().network_peer == null:
		return false
	else:
		return true

####
## Client networking functions
####

func create_client(address : String, port : int):
	get_tree().connect("network_peer_connected", self, "_on_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_peer_disconnected")
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	get_tree().connect("connection_failed", self, "_on_connection_failed")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")
	network.create_client(address, port)
	get_tree().set_network_peer(network)
	Logger.out([Logger.get_prefix("Networking", "Info"), "Now connecting to ", address, ":", str(port), "!"])

# Request movement information from server
func update_player_local(dbf, drl):
	rpc_id(1, "update_player", dbf, drl)

remote func update_peer(t : Vector3, ry : float, hrx : float , v : Vector3):
	var peer = Game.main.get_node(str(get_tree().get_rpc_sender_id())).body
	peer.translation = t
	peer.rotation.y = ry
	peer.get_node("Head").rotation.x = hrx
	peer.get_parent().velocity = v

remote func kicked(reason : String):
	Logger.out([Logger.get_prefix("Networking", "Info"), "You have been kicked from the server. Reason: ", reason])
	server_disconnect()

####
## Server networking functions
####

func create_server(port : int):
	get_tree().connect("network_peer_connected", self, "_on_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_peer_disconnected")
	network.create_server(port, MAX_PLAYERS)
	get_tree().set_network_peer(network)
	Logger.out([Logger.get_prefix("Networking", "Info"), "Now hosting a new server on port ", str(port), "!"])

func server_disconnect():
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
	get_tree().network_peer = null
	network.close_connection()
	Game.menu.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

remotesync func update_player(dbf, drl):
	Game.main.get_node(str(get_tree().get_rpc_sender_id())).direction += dbf + drl

puppet func update_world(world_state : Array):
	for player in world_state[0]:
		print(player)
		if int(player[0]) == get_tree().get_network_unique_id():
			continue
		Game.main.get_node(player[0]).update(player[1], player[2], player[3], player[4])

##
# Events
##

func _on_peer_connected(id):
	Logger.out([Logger.get_prefix("Networking", "Info"), str(id), " has connected to the server!"])
	Game.spawn_controller(str(id), 1)
	
func _on_peer_disconnected(id):
	Logger.out([Logger.get_prefix("Networking", "Info"), str(id), " has disconnected."])
	Game.remove_controller(id)

func _on_connected_to_server():
	Logger.out([Logger.get_prefix("Networking", "Info"), "Now connected to a server."])
	var id = get_tree().get_network_unique_id()
	Game.spawn_map(0)
	Game.spawn_controller(str(id), 0)
	Game.toggle_menu()
	
func _on_connection_failed():
	Logger.out([Logger.get_prefix("Networking", "Info"), "Connection to the server failed!"])

func _on_server_disconnected():
	Logger.out([Logger.get_prefix("Networking", "Info"), "You have lost connection to the server."])
	server_disconnect()
