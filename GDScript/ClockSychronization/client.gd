class_name client extends ClockSynch

## Synchronize server and client clocks
##
## Client subclass synchronizes the clocks between the game servers and the clients as
## well as adding some network latency normalization so that all client experience the same
## amount of network latency.
	
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
	print(avg_latency_msec)
	client_clock_msec = server_time_msec + avg_latency_msec

@rpc("call_local")
func CalculateLatency() -> void:
	CalculateLatency.rpc_id(1, int(Time.get_unix_time_from_system() * 1000))
	
@rpc()
func GetServerTime() -> void:
	pass
