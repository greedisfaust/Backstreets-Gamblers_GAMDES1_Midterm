extends CSGBox3D
# Door is red until quota is met, then glows green (GDD 5.4 / 7.2).

var mat := StandardMaterial3D.new()

func _ready() -> void:
	material = mat
	mat.emission_enabled = true
	GameState.quota_status_changed.connect(_on_status)
	_on_status(false)

func _on_status(met: bool) -> void:
	var c := Color.LIME_GREEN if met else Color(0.6, 0.1, 0.1)
	mat.albedo_color = c
	mat.emission = c
	mat.emission_energy_multiplier = 1.5 if met else 0.3
