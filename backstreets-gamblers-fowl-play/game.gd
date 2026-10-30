extends Node3D

func _ready() -> void:
	GameState.day_time = 300.0   # testing only
	GameState.day_started.connect(func(d, q, _t): print("Day ", d, " quota ", q))
	GameState.day_ended.connect(func(m): print("Day ended, met: ", m))
	GameState.wallet_changed.connect(func(b): print("Wallet ", b))
	GameState.start_run()
	Audio.start_music()
	get_tree().create_timer(3.0).timeout.connect(func():
		GameState.message.emit("THE HOUSE: You ate the wings. You are bound. Win your freedom."))
