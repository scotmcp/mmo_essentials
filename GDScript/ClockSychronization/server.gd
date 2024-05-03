class_name Server extends ClockSynch

## Clock Synchronizer and Network Latency normalizer
##
## 

## must be created and supplied by the server or client peer


@rpc("any_peer", "unreliable_ordered")
func GetServerTime(client_time) -> void:
	var client_id = multiplayer.get_remote_sender_id()
	ReturnServerTime.rpc_id(client_id, int(Time.get_unix_time_from_system() * 1000), client_time)
	
@rpc("any_peer")
func CalculateLatency(client_time) -> void:
	var client_id = multiplayer.get_remote_sender_id()
	ReturnLatency.rpc_id(client_id, client_time)

@rpc()
func ReturnServerTime() -> void:
	pass
	
@rpc()
func ReturnLatency() -> void:
	pass	
	
