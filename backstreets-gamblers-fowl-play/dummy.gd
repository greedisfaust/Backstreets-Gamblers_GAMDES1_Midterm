extends StaticBody3D
# Stationary "teammate": a hit knocks it into a limp pose (scripted, not ragdoll).

const STUN_TIME := 5.0   # PROVISIONAL stun length
var stunned := false

func stun() -> void:
	if stunned:
		return
	stunned = true
	var t := create_tween()
	t.tween_property(self, "rotation_degrees:x", -90.0, 0.2)
	t.tween_interval(STUN_TIME)
	t.tween_property(self, "rotation_degrees:x", 0.0, 0.3)
	t.tween_callback(func(): stunned = false)
