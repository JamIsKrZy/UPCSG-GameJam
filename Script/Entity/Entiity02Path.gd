class_name Entity02Path extends PathFollow3D

@onready var audio: AudioStreamPlayer3D = $audio



func play_audio():
	if audio.playing: return
	audio.play()

func _stop_audio():
	audio.stop()

#  use tween to move back
func fade_out():
	var tween: Tween = get_tree().create_tween();
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		self,
		"progress_ratio",
		0.,
		3.
	)
	tween.finished.connect(_stop_audio)
