class_name Client extends Node

## Synchronize server and client clocks
##
## Client subclass synchronizes the clocks between the game servers and the clients as
## well as adding some network latency normalization so that all client experience the same
## amount of network latency.

## @experimental
## Synchronize server and client clocks
##
## This class synchronizes the clocks between the game servers and the clients as
## well as adding some network latency normalization so that all client experience the same
## amount of network latency. See [ClockSynch.Client] and [ClockSynch.Server] for more information.

# Client Settings
var client = ENetMultiplayerPeer.new()
var server_ip_address = "127.0.0.1"
var port : int = 8888

# Clock Synch and Latency variables
var cumulative_delta_decimal : float = 0
var avg_latency_msec : int
var client_clock_msec : int
var latency_array : Array = []
var latency_source_array : Array = []
var delta_latency_msec : = 0


func ConnectToServer() -> void:
	print("Starting Client...")
	client.create_client(server_ip_address, port)
	multiplayer.multiplayer_peer = client
	print("Contacting Server...")
	
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.server_disconnected.connect(_disconnected_from_server)
	multiplayer.connection_failed.connect(_connection_to_server_failed)
	
func _connected_to_server() -> void:
	var client_id = multiplayer.get_unique_id()
	print("Connected to Server, client ID is: %s" % client_id)
	GetServerTime.rpc_id(1, int(Time.get_unix_time_from_system() * 1000))
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.timeout.connect(CalculateLatency)
	self.add_child(timer)
	
func _connection_to_server_failed() -> void:
	print("Connection to server failed")

func _disconnected_from_server() -> void:
	print("Disconnected from server")
	
func _physics_process(delta: float) -> void:
	client_clock_msec += int(delta * 1000) + delta_latency_msec
	delta_latency_msec = 0
	cumulative_delta_decimal += (delta * 1000) - (int(delta) * 1000)
	if cumulative_delta_decimal >= 1.0:
		client_clock_msec += 1
		cumulative_delta_decimal -= 1.0


## Return Latency
@rpc("authority", "unreliable_ordered")
func ReturnLatency(client_time) -> void:
	latency_source_array.append(((Time.get_unix_time_from_system() * 1000) - client_time) / 2)
	if latency_source_array.size() == 9:
		latency_array = latency_source_array.duplicate(false)
		var total_latency = 0
		latency_array.sort()
		var median_latency = latency_array[4]
		for i in range(latency_array.size()-1,-1,-1):
			if latency_array[i] > (2 * median_latency) and latency_array[i] > 20:
				latency_array.remove_at(i)
			else:
				total_latency += latency_array[i]
		delta_latency_msec = (total_latency / latency_array.size()) - avg_latency_msec
		avg_latency_msec = total_latency / latency_array.size()
		print("Latency = " + str(avg_latency_msec))
		print("Delta Latency = " + str(delta_latency_msec))
		latency_source_array.remove_at(0)
		

@rpc("authority", "unreliable_ordered")
func ReturnServerTime(server_time_msec, client_time_msec) -> void:
	var current_time = int(Time.get_unix_time_from_system() * 1000)
	avg_latency_msec =  (current_time - client_time_msec) / 2
	client_clock_msec = server_time_msec + avg_latency_msec
	print(avg_latency_msec)

@rpc("call_local")
func CalculateLatency() -> void:
	CalculateLatency.rpc_id(1, int(Time.get_unix_time_from_system() * 1000))
	
@rpc()
func GetServerTime() -> void:
	pass
