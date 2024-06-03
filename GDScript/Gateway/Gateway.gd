extends Node

var DEBUG : bool = Log.DEBUG

var network = ENetMultiplayerPeer.new()
var gateway_api : MultiplayerAPI
@onready var gateway: Node = $"."

var port = 7776
var max_players = 100
var cert = load("res://X509_Certificate.crt")
var key = load("res://x509_Key.key")
var dtls_options = TLSOptions.server(key, cert)
func _ready() -> void:
	StartServer()

func _process(delta: float) -> void:
	if not get_multiplayer() == null:
		return;
	gateway_api.poll();
	
	
func StartServer() -> void:
	Log.info("Starting client gateway server...")
	gateway_api = MultiplayerAPI.create_default_interface()
	network.create_server(port, max_players)
	network.host.dtls_server_setup(dtls_options)
	get_tree().set_multiplayer(gateway_api, gateway.get_path())
	gateway_api.multiplayer_peer = network
	
	network.peer_connected.connect(_peer_connected)
	network.peer_disconnected.connect(_peer_disconnected)
	
	
	
	var network_id = network.get_unique_id()
	var gateway_id = gateway_api.get_unique_id()
	
	Log.info("Client Gateway ID: %s " % str(gateway_id))
	
	
func _peer_connected(client_id) -> void:
	Log.info("User " + str(client_id) + " connected to Authentication Server")
	
	
func _peer_disconnected(client_id) -> void:
	Log.info("User " + str(client_id) + " disconnected")
	
	
# Incoming RPCs

@rpc("any_peer", "call_remote")
func RequestLogin(username, password) -> void:
	Log.info("Login request received")
	Log.info(username + " " + password)
	var client_id = gateway_api.get_remote_sender_id()
	Authenticate.AuthenticatePlayer(client_id, username, password) 
	
	
@rpc("any_peer", "call_remote")
func RequestCreateAccount(username, password, email) -> void:
	Log.info("Account creation request received for:")
	Log.info(username + " | " + email + " | " + password)
	var client_id = gateway_api.get_remote_sender_id()
	Authenticate.CreateAccount(client_id, username, password, email) 
	
	
# Outgoing RPCs
@rpc()
func ReturnLoginRequest(client_id, result, token) -> void:
	Log.info("Forwarding reply to player, client_id: " + str(client_id))
	ReturnLoginRequest.rpc_id(client_id, result, token)
	await get_tree().create_timer(3).timeout
	network.disconnect_peer(client_id)
	
@rpc()
func AccountCreationResults(client_id, result) -> void:
	Log.info("Forwarding reply to player, client_id: " + str(client_id))
	AccountCreationResults.rpc_id(client_id, result)
	await get_tree().create_timer(3).timeout
	network.disconnect_peer(client_id)
