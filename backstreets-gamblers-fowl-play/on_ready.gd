extends Node
func _ready() -> void:
	GameState.day_started.connect(func(d, q, t): print("Day ", d, " quota ", q, " max bet ", GameState.max_bet()))
	GameState.day_ended.connect(func(m): print("Day ended, met: ", m))
	GameState.start_run()
	GameState.day_time = 2.0
