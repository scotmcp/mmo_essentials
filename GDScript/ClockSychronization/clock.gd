class_name ClockSynch extends Node
## @experimental
## Synchronize server and client clocks
##
## This class synchronizes the clocks between the game servers and the clients as
## well as adding some network latency normalization so that all client experience the same
## amount of network latency. See [ClockSynch.Client] and [ClockSynch.Server] for more information.

var cumulative_delta_decimal : float = 0
var avg_latency_msec : int
var client_clock_msec : int
var latency_array : Array = []
var latency_source_array : Array = []
var delta_latency_msec : = 0

func _physics_process(delta: float) -> void:
	client_clock_msec += int(delta * 1000) + delta_latency_msec
	delta_latency_msec = 0
	cumulative_delta_decimal += (delta * 1000) - (int(delta) * 1000)
	if cumulative_delta_decimal >= 1.0:
		client_clock_msec += 1
		cumulative_delta_decimal -= 1.0

