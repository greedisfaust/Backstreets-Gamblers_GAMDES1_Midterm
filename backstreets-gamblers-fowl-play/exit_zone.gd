extends Area3D
# Exit zone (GDD 8.5): ends the day early once quota is met.

signal exit_zone_filled
var inside := false

func _ready() -> void:
	body_entered.connect(func(b): if b.is_in_group("player"): inside = true)
	body_exited.connect(func(b): if b.is_in_group("player"): inside = false)
	exit_zone_filled.connect(GameState.try_early_end)

func _physics_process(_delta: float) -> void:
	if inside and GameState.running and GameState.wallet >= GameState.quota:
		exit_zone_filled.emit()
