extends Node

var DEBUG : bool = Log.DEBUG

var network = ENetMultiplayerPeer.new()
var ip : String = "192.168.1.100"
var port : int = 7777
var logon_attempts : int

func _ready() -> void:
	ConnectToServer()
	
func ConnectToServer() -> void:
	Log.info("Connecting to Authentication Server...")
	network.create_client(ip,port)
	self.multiplayer.multiplayer_peer = network
	
	self.multiplayer.connected_to_server.connect(_on_connected_to_server)
	self.multiplayer.connection_failed.connect(_on_connection_failed)
	self.multiplayer.server_disconnected.connect(_on_disconnected_from_server)
	
	#var network_id = network.get_unique_id()
	
func _on_connected_to_server() -> void:
	logon_attempts = 0
	var network_id = network.get_unique_id()
	Log.info("Successfully connected to authentication server")
	Log.info("Authentication Client: " + str(network_id))
	
func _on_connection_failed() -> void:
	logon_attempts += 1
	Log.error("Failed to connect to Authentication Server, reattempting to connect. Attempt#: %s " % str(logon_attempts))
	await(get_tree().create_timer(2.0).timeout)
	ConnectToServer()
	
func _on_disconnected_from_server() -> void:
	self.multiplayer.connected_to_server.disconnect(_on_connected_to_server)
	self.multiplayer.connection_failed.disconnect(_on_connection_failed)
	self.multiplayer.server_disconnected.disconnect(_on_disconnected_from_server)
	logon_attempts += 1
	Log.info("Disconnected from Authentication Server, attempting to reconnect. Attempt#: %s " % str(logon_attempts))
	await(get_tree().create_timer(2.0).timeout)
	ConnectToServer()

# Outgoing RPCs
@rpc("call_local", "reliable")
func AuthenticatePlayer(client_id, username, password) -> void:
	Log.info("Forwarding authentication request")
	AuthenticatePlayer.rpc_id(1, client_id, username, password)
	
@rpc("call_local", "reliable")
func CreateAccount(client_id, username, password, email) -> void:
	Log.info("Forwarding Account Creation Request")
	CreateAccount.rpc_id(1, client_id, username, password, email)
	
# Incoming RPCs
@rpc("authority","reliable")
func AuthenticationResults(client_id, result, token) -> void:
	Log.info("Result: " + str(result) + " received and replying")
	Gateway.ReturnLoginRequest(client_id, result, token)
	
@rpc("authority","reliable")
func AccountCreationResults(client_id, result) -> void:
	Log.info("Result: " + str(result) + " received and replying")
	Gateway.AccountCreationResults(client_id, result)
	
