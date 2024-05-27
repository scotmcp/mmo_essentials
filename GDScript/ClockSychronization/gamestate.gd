class_name GameState extends Client
## @experimental
## Synchronize server and client clocks
##
## This class synchronizes the clocks between the game servers and the clients as
## well as adding some network latency normalization so that all client experience the same
## amount of network latency. See [ClockSynch.Client] and [ClockSynch.Server] for more information.

var last_world_state = 0
var world_state_buffer : Array = []
var interpolation_offset : int ## how much time to allow for gathering state frames

func UpdateWorldState(world_state) -> void:
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)
		
func _physics_process(_delta: float) -> void:
	#var local_time = int(Time.get_unix_time_from_system() * 1000) - interpolation_offset
	var offset_time = client_clock_msec - interpolation_offset
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and offset_time > world_state_buffer[2].T:
			world_state_buffer.remove_at(0)
			# The next line slows the game down significantly.
			# comment when no longer needed
			print(str(world_state_buffer))
			
		if world_state_buffer.size() > 2:
			var interpolation_factor = float(offset_time - world_state_buffer[1]["T"]) \
				/ float(world_state_buffer[2]["T"] - world_state_buffer[1]["T"])
			interpolate(world_state_buffer, interpolation_factor, offset_time)
	
		elif offset_time > world_state_buffer[1].T:
			var lerp_factor = float(offset_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"]) - 1.0
			extrapolate(world_state_buffer, lerp_factor, offset_time)


func interpolate(world_state_buffer, interpolation_factor, local_time) -> void:
	if world_state_buffer.size() > 2:
		interpolate_players(world_state_buffer, interpolation_factor, local_time)
		interpolate_enemies(world_state_buffer, interpolation_factor, local_time)

func interpolate_players(world_state_buffer, interpolation_factor, local_time) -> void:
	for player in world_state_buffer[2]["C"].keys():
		if int(player) != multiplayer.get_unique_id():
			if !world_state_buffer[1]["C"].has(player):
				continue
			if get_node("/root/Main/NetworkPlayers").has_node(str(player)):
				var position_lerp = lerp(world_state_buffer[1]["C"][player]["P"], world_state_buffer[2]["C"][player]["P"], interpolation_factor)
				var rotation_lerp = lerp(world_state_buffer[1]["C"][player]["R"], world_state_buffer[2]["C"][player]["R"], interpolation_factor)
				var animation_state : int = world_state_buffer[2]["C"][player]["S"]
				get_node("/root/Main/NetworkPlayers/" + str(player)).MovePlayer(position_lerp, rotation_lerp)
			#else:
				#SpawnPlayer(player, world_state_buffer[0]["C"][player]["P"])

func interpolate_enemies(world_state_buffer, interpolation_factor, local_time) -> void:
	for enemy in world_state_buffer[2]["E"].keys():
		if not world_state_buffer[1]["E"].has(enemy):
			continue
		if get_node("/root/Main/Enemies").has_node(str(enemy)):
			var position_lerp = (lerp(world_state_buffer[1]["E"][enemy]["P"], world_state_buffer[2]["E"][enemy]["P"], interpolation_factor ))
			get_node("/root/Main/Enemies/" + str(enemy)).MoveEnemy(position_lerp)
			get_node("/root/Main/Enemies/" + str(enemy)).Health(world_state_buffer[1]["E"][enemy]["P"])
		#else:
			#SpawnEnemy(enemy, world_state_buffer[2]["E"][enemy]["P"])


			
func extrapolate(world_state_buffer, lerp_factor, local_time) -> void:
	# need to split up like done for interpolation
	for player in world_state_buffer[1]["C"].keys():
		if int(player) != multiplayer.get_unique_id():
			if !world_state_buffer[0].has(player):
				continue
			if get_node("/root/Main/NetworkPlayers").has_node(str(player)):
				var position_delta = (world_state_buffer[1]["C"][player]["P"] - world_state_buffer[0]["C"][player]["P"])
				var position_lerp = world_state_buffer[1]["C"][player]["P"] + (position_delta * lerp_factor)
				var rotation_delta = (world_state_buffer[1]["C"][player]["R"] - world_state_buffer[0]["C"][player]["R"])
				var rotation_lerp = world_state_buffer[1]["C"][player]["P"]  + (rotation_delta * lerp_factor)
				get_node("/root/Main/NetworkPlayers/" + str(player)).MovePlayer(position_lerp, rotation_lerp)
			#else: # Do we even need this?
				#SpawnPlayer(player, world_state_buffer[1]["C"][player]["P"])
