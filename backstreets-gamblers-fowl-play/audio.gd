extends Node
# Procedural placeholder audio (original, generated in code). Autoload name: Audio

const RATE := 22050
var sounds := {}
var music: AudioStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	sounds["bet"] = _make([[440, 0.08]])
	sounds["step"] = _make([[600, 0.07]])
	sounds["win"] = _make([[523, 0.09], [659, 0.09], [784, 0.18]])
	sounds["bust"] = _make([[160, 0.35]], true)
	sounds["hit"] = _make([[220, 0.06], [140, 0.1]], true)
	sounds["day_start"] = _make([[523, 0.12], [784, 0.25]])
	sounds["day_ok"] = _make([[659, 0.1], [784, 0.1], [988, 0.25]])
	sounds["day_fail"] = _make([[300, 0.2], [220, 0.35]], true)
	sounds["extra"] = _make([[120, 0.6]], true)
	sounds["won"] = _make([[523, 0.12], [659, 0.12], [784, 0.12], [1047, 0.4]])
	sounds["over"] = _make([[400, 0.2], [300, 0.2], [200, 0.2], [100, 0.6]], true)
	music = AudioStreamPlayer.new()
	music.stream = _make([[196, 0.25], [233, 0.25], [294, 0.25], [233, 0.25], [196, 0.25], [233, 0.25], [349, 0.25], [294, 0.25]], false, true)
	music.volume_db = -16
	add_child(music)
	GameState.day_started.connect(func(_d, _q, _t): play("day_start"))
	GameState.day_ended.connect(func(m): play("day_ok" if m else "day_fail"))
	GameState.extra_life_spent.connect(func(): play("extra"))
	GameState.run_won.connect(func(): play("won"))
	GameState.game_over.connect(func(): play("over"))

func play(sound_name: String) -> void:
	var p := AudioStreamPlayer.new()
	p.stream = sounds[sound_name]
	p.volume_db = -6
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()

func start_music() -> void:
	if not music.playing:
		music.play()

func stop_music() -> void:
	music.stop()

func _make(notes: Array, square := false, loop := false) -> AudioStreamWAV:
	var total := 0
	for n in notes:
		var d: float = n[1]
		total += int(d * RATE)
	var bytes := PackedByteArray()
	bytes.resize(total * 2)
	var idx := 0
	for n in notes:
		var freq: float = n[0]
		var count := int(float(n[1]) * RATE)
		for i in count:
			var s: float = sin(TAU * freq * i / RATE)
			if square:
				s = 1.0 if s >= 0.0 else -1.0
			var env: float = 1.0 - float(i) / count
			bytes.encode_s16(idx * 2, int(s * env * 0.35 * 32767))
			idx += 1
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.stereo = false
	w.data = bytes
	if loop:
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = total
	return w
