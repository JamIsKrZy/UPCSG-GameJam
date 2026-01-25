class_name AudioSystemClass extends Node

var bus_handlers: Dictionary[StringName, BusHandler] = {}

var task_queue: Dictionary[int, Callable] = {}


static func _get_bus_enum() -> String:
	var bus_names: PackedStringArray = []
	for bus_idx in range(AudioServer.bus_count):
		var bus_name := AudioServer.get_bus_name(bus_idx)
		bus_names.append(bus_name)

	return ",".join(bus_names)

func add_stream(stream: AudioResource) -> AudioStreamPlayer:
	var assigned_bus: StringName = stream.get_assigned_bus()
	var bus_handler: BusHandler = bus_handlers.get(assigned_bus);
	if bus_handler == null:
		printerr("[AudioSystem] Bus name \"", assigned_bus, "\" does not exist!")
		return null

	var player: AudioStreamPlayer = bus_handler.insert_stream(stream)
	if player == null:
		printerr("[AudioSystem] Audio Player \"", assigned_bus, "\" already exists!")

	return player

"""
@return: returns true if found, false not found
"""
func play_stream(bus: StringName, stream: StringName) -> bool:
	var bus_handler: BusHandler = bus_handlers.get(bus);
	if bus_handler == null: return false

	var player: AudioStreamPlayer = bus_handler.get_audio_stream(stream);
	if player == null: return false

	player.play()

	return true

"""
@return: returns true if processed, false not found
"""
func play_stream_fade_in(bus: StringName, stream: StringName, duration: float = 1.5) -> bool:
	var bus_handler: BusHandler = _get_bus_handler(bus);
	if bus_handler == null: return false

	var player: AudioStreamPlayer = bus_handler.get_audio_stream(stream);
	if player == null: return false

	var defined_volume = player.volume_linear
	player.volume_linear = 0.0
	player.play()

	var task: Callable = AudioSystemClass.make_fade_volume_to(
		player,
		defined_volume,
		duration
	)

	self._append_task_queue(task)

	return true



func stop_streams(bus: StringName):
	"""
	Stops all the audio streams that is currenly playing in
	the bus
	"""
	var bus_handler = _get_bus_handler(bus)
	if bus_handler == null: return

	var streams: Array[AudioStreamPlayer] = bus_handler.streams()
	for stream: AudioStreamPlayer in streams:
		stream.stop()



func stop_stream(bus: StringName, stream: StringName):
	var handler: BusHandler = _get_bus_handler(bus)
	if handler == null: return

	var player: AudioStreamPlayer = handler.get_audio_stream(stream)
	if player == null: return
	player.stop()


func set_stream_volume(
	bus: StringName,
	stream: StringName,
	target: float,
):
	var handler: BusHandler = _get_bus_handler(bus)
	if handler == null: return

	var player: AudioStreamPlayer = handler.get_audio_stream(stream)
	if player == null: return

	player.volume_linear = target



func set_stream_volume_fade(
	bus: StringName,
	stream: StringName,
	target: float,
	duration: float = 1.
):
	var handler: BusHandler = _get_bus_handler(bus)
	if handler == null: return

	var player: AudioStreamPlayer = handler.get_audio_stream(stream)
	if player == null: return

	var task: Callable = AudioSystemClass.make_fade_volume_to(
		player,
		target,
		duration
	)

	self._append_task_queue(task)

func pause_stream(bus: StringName, stream: StringName) -> bool:
	var handler: BusHandler = _get_bus_handler(bus)
	if handler == null: return false

	var player: AudioStreamPlayer = handler.get_audio_stream(stream)
	if player == null: return false

	player.stream_paused = true

	return true

func pause_stream_fade(bus: StringName, stream: StringName, duration: float = 1.5) -> bool:
	var handler: BusHandler = _get_bus_handler(bus)
	if handler == null: return false

	var player: AudioStreamPlayer = handler.get_audio_stream(stream)
	if player == null: return false

	var after_task: Callable = func after_call(passed_stream: AudioStreamPlayer):
		passed_stream.stream_paused = true

	var task: Callable = AudioSystemClass.make_fade_volume_to(
		player,
		0.,
		duration,
		after_task
	)

	self._append_task_queue(task)
	return true

func resume_stream(bus: StringName, stream: StringName) -> bool:
	var handler: BusHandler = _get_bus_handler(bus)
	if handler == null: return false

	var player: AudioStreamPlayer = handler.get_audio_stream(stream)
	if player == null: return false

	player.stream_paused = false

	return true

func resume_stream_fade(bus: StringName, stream: StringName, target: float, duration: float = 1.) -> bool:
	var handler: BusHandler = _get_bus_handler(bus)
	if handler == null: return false

	var player: AudioStreamPlayer = handler.get_audio_stream(stream)
	if player == null: return false

	player.volume_linear = 0.
	player.stream_paused = false

	var task: Callable = AudioSystemClass.make_fade_volume_to(
		player,
		target,
		duration
	)

	self._append_task_queue(task)

	return true


func mute_bus(bus: StringName):
	var handler = bus_handlers.get(bus)
	if handler == null: return

	AudioServer.set_bus_volume_db(handler.idx, -80.)




# clamp the ratio to avoid out of boundaries
func set_bus_volume(bus: StringName, ratio: float) -> bool:
	var handler = bus_handlers.get(bus)
	if handler == null: return false

	var clamped = clampf(ratio, 0.0, 1.0)

	AudioServer.set_bus_volume_linear(handler.idx, clamped)
	return true



# transition fade is in transition
func set_bus_volume_fade(
	bus: StringName,
	stream: StringName,
	to: float,
	duration: float = 1.
):
	pass

# WIP
func load_bus():
	pass

# WIP
func drop_bus():
	pass

func _get_bus_handler(bus: StringName) -> BusHandler:
	var bus_handler: BusHandler = bus_handlers.get(bus);
	if bus_handler == null:
		printerr("Bus name: \"", bus, "\" is not registered in the audio manager")
	return bus_handler

func _load_default_bus_layout():
	pass

func _clean_streams():
	# clean all the temporary references of BusStreams
	print("[DEBUG][AudioSystem] CLEANING...")
	for stream: BusHandler in bus_handlers.values():
		var tasks: Array[Callable] = stream.clean()

		for task in tasks:
			self._append_task_queue(task)

func _force_clean_streams():
	# clean all the temporary and Persistent references of BusStreams
	for handler: BusHandler in bus_handlers.values():
		handler.force_clean()

# func _debug_audio_tree():
# 	for bus_handler: BusHandler in bus_handlers.values():
# 		for temp: StringName in bus_handler.temporary_streams.keys():
# 			print("---", temp)

# 		for temp: StringName in bus_handler.persistent_streams.keys():
# 			print(temp)

func _ready() -> void:
	for bus_idx in range(AudioServer.bus_count):
		var bus_name = AudioServer.get_bus_name(bus_idx)
		print("[DEBUG] Registering bus -- ", bus_name, " into AudioManager")
		var handler: BusHandler = BusHandler.new(bus_name, bus_idx)

		var node = handler.get_node()
		add_child(node)

		bus_handlers.set(bus_name, handler)


func _append_task_queue(process: Callable):
	task_queue.set(process.get_object_id(), process)


func _process(delta: float) -> void:
	# process process_handler
	if task_queue.is_empty(): return
	for process: Callable in task_queue.values():
		var is_done = process.call()
		if is_done:
			var id = process.get_object_id()
			task_queue.erase(id)


"""
@param after - it will pass reference of stream
"""
static func make_fade_volume_to(
	stream: AudioStreamPlayer,
	target_volume: float,
	duration: float = 1.5,
	after: Callable = Callable()
) -> Callable:
	var start_time: int = Time.get_ticks_msec()
	var end_time: int = start_time + int(duration * 1000.0)
	var start_vol: float = stream.volume_linear

	return func() -> bool:
		var now: int = Time.get_ticks_msec()

		var progress: float = inverse_lerp(start_time, end_time, now)
		progress = clampf( progress, 0.0, 1.0)

		stream.volume_linear = lerp(start_vol, target_volume, progress)

		if progress >= 1.0:
			if not after.is_null(): after.call(stream)
			return true
		else:
			return false



## Use this function only when fading out the audio
## then drop from the scene tree
static func make_fade_out_then_drop(
	stream: AudioStreamPlayer,
	duration: float = 1.5
) -> Callable:
	var start_time: int = Time.get_ticks_msec()
	var end_time: int = start_time + int(duration * 1000.0)
	var start_vol: float = stream.volume_linear

	return func() -> bool:
		var now: int = Time.get_ticks_msec()

		var progress: float = inverse_lerp(start_time, end_time, now)
		progress = clampf( progress, 0.0, 1.0)

		stream.volume_linear = lerp(start_vol, 0.0, progress)

		if progress >= 1.0:
			stream
			stream.queue_free()
			return true
		else:
			return false


class BusHandler:
	var bus_name: StringName
	var idx: int


	var bus_node: Node
	var temp_node: Node
	var pers_node: Node


	var temporary_streams: Dictionary[StringName, AudioStreamPlayer] = {}
	var persistent_streams: Dictionary[StringName, AudioStreamPlayer] = {}

	func _init(name: StringName, idx: int) -> void:
		self.bus_name = name
		self.idx = idx
		self.bus_node = Node.new()

		self.bus_node.name = name
		_init_subtree()


	func _init_subtree():
		var temp_node := Node.new()
		var pers_node := Node.new()

		self.temp_node = temp_node
		self.pers_node = pers_node

		temp_node.name = "temporary_audio"
		pers_node.name = "persistent_audio"

		self.bus_node.add_child(temp_node)
		self.bus_node.add_child(pers_node)


	func insert_stream(stream: AudioResource) -> AudioStreamPlayer:
		if temporary_streams.has(stream.name) or persistent_streams.has(stream.name): return null
		var stream_player: AudioStreamPlayer = stream.to_stream_player();
		stream_player.name = stream.name

		match stream.lifetime:
			AudioResource.AudioResourceLifetime.PERSISTENT:
				persistent_streams.set(stream.name, stream_player)
				self.pers_node.add_child(stream_player)
			AudioResource.AudioResourceLifetime.TEMPORARY:
				temporary_streams.set(stream.name, stream_player)
				self.temp_node.add_child(stream_player)

		return stream_player



	func streams() -> Array[AudioStreamPlayer]:
		var stream_1 = temporary_streams.values()
		var stream_2 = persistent_streams.values()
		stream_1.append_array(stream_2)
		return stream_1

	func get_node() -> Node:
		return self.bus_node

	func get_audio_stream(name: StringName) -> AudioStreamPlayer:
		"""
		This is only encourage to call within the audiomanager
		avoid leaking audio stream outside AudioManager
		"""
		var player = temporary_streams.get(name)
		if player == null:
			player = persistent_streams.get(name)

		if player == null:
			printerr("audio stream name: \"", name, "\" is not registered in the audio manager")
		return player



	func _debug_list():
		print("Debuginng Bus Audio Keys:")
		for key in temporary_streams.keys():
			print(key)

		for key in persistent_streams.keys():
			print(key)

	# returns callables to process for fade out
	func clean() -> Array[Callable]:
		var process_fade_out: Array[Callable]
		for player in temporary_streams.values():
			if player and is_instance_valid(player):
				if player.playing:
					var process = AudioSystemClass.make_fade_out_then_drop(player, 1.5)
					process_fade_out.append(process)
				else:
					player.queue_free()

		temporary_streams.clear()
		return process_fade_out



	func force_clean():
		""
		temporary_streams.clear()
		# persistent_streams.clear()
