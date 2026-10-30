extends Control
const GAME_SCENE := "res://game.tscn"   # change if your game.tscn is in a folder (right-click > Copy Path)

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color(0.12, 0.05, 0.05)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	center.add_child(box)
	box.add_child(_label("FOWL PLAY", 64))
	box.add_child(_label("Gamble your way out of The House's contract.", 20))
	var play := _button("Play")
	play.pressed.connect(func(): get_tree().change_scene_to_file(GAME_SCENE))
	box.add_child(play)
	var quit := _button("Quit")
	quit.pressed.connect(func(): get_tree().quit())
	box.add_child(quit)
	box.add_child(_label("WASD move | Mouse look | E sit/leave | Space bet/push | C cash out | Left click hit", 16))

func _label(text: String, size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l

func _button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(240, 48)
	return b
