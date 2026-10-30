extends Node3D
# Quick visual pass: ambient light, colors, and a sign so the setting reads as a casino.

func _ready() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.08, 0.03, 0.03)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(1.0, 0.9, 0.8)
	env.ambient_light_energy = 0.7
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)

	for c in get_children():
		if not (c is CSGPrimitive3D) or c.name == "ExitDoor":
			continue
		var n := String(c.name).to_lower()
		if n.begins_with("floor"):
			_paint(c, Color(0.45, 0.08, 0.12))    # red carpet
		elif n.begins_with("wall"):
			_paint(c, Color(0.30, 0.06, 0.09))    # dark red walls
		elif n.contains("cylinder") or n.contains("table"):
			_paint(c, Color(0.10, 0.45, 0.22))    # green felt

	var sign_label := Label3D.new()
	sign_label.text = "THE HOUSE\nWings for life!"
	sign_label.position = Vector3(0, 2.5, -9.7)
	sign_label.pixel_size = 0.01
	sign_label.font_size = 96
	sign_label.modulate = Color(1.0, 0.8, 0.2)
	add_child(sign_label)

func _paint(node: CSGPrimitive3D, color: Color) -> void:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	node.material = m
