@tool
class_name AudioResource extends Resource



## AudioResourceeLifetime is for additional data for lifetime of the object
## Once the scene tree changes, Temporary lifetime will be dropped, except for Persistent lifetime
enum AudioResourceLifetime { TEMPORARY, PERSISTENT }


@export var name: StringName = &""
@export var stream: AudioStream = null
@export_range(0., 1., 0.01) var volume_db: float = 1.
@export_range(0.01, 4.0, 0.01) var pitch_scale: float = 1.
@export var loop: bool = false
@export var lifetime: AudioResourceLifetime = AudioResourceLifetime.TEMPORARY
var _bus: StringName = &"":
	get(): return _bus
	set(assign_bus): _bus = assign_bus






func get_assigned_bus() -> StringName:
	return _bus

func to_stream_player() -> AudioStreamPlayer:
	stream.loop = loop

	var stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
	stream_player.bus = _bus
	stream_player.stream = self.stream
	stream_player.autoplay = false
	stream_player.pitch_scale = self.pitch_scale
	stream_player.volume_linear = self.volume_db
	return stream_player

func is_temporary() -> bool:
	return self.lifetime == AudioResourceLifetime.TEMPORARY

func is_persistent() -> bool:
	return self.lifetime == AudioResourceLifetime.PERSISTENT


func _get_property_list() -> Array[Dictionary]:
	if not Engine.is_editor_hint(): return []
	var list: Array[Dictionary] = []

	list.append({
		"name": "_bus",
		"type": TYPE_STRING_NAME,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": AudioSystemClass._get_bus_enum()
	})


	return list
