extends DirectionalLight3D
# Lighting reacts to the run state (GDD 3.4 / 7.2).

func _ready() -> void:
	GameState.day_started.connect(func(_d, _q, _t): _set_tone())
	GameState.extra_life_spent.connect(_set_tone)
	GameState.game_over.connect(func(): light_energy = 0.0)   # lights cut

func _set_tone() -> void:
	if GameState.extra_life:
		light_color = Color.WHITE
		light_energy = 1.0
	else:
		light_color = Color(1.0, 0.45, 0.35)   # harsher final-life tone
		light_energy = 0.6
