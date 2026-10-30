extends CanvasLayer
const MENU_SCENE := "res://main_menu.tscn"   # change if in a folder

var pause_panel: Control
var win_panel: Control
var over_panel: Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	pause_panel = _make_panel("PAUSED", [["Resume", _resume], ["Main Menu", _to_menu]])
	win_panel = _make_panel("CONTRACT VOIDED\nThe House lets you go.", [["Play again", _restart], ["Main Menu", _to_menu]])
	over_panel = _make_panel("GAME OVER\nThe House keeps you.", [["Try again", _restart], ["Main Menu", _to_menu]])
	GameState.run_won.connect(func(): _show(win_panel))
	GameState.game_over.connect(func(): _show(over_panel))

func _make_panel(title: String, buttons: Array) -> Control:
	var root := ColorRect.new()
	root.color = Color(0, 0, 0, 0.75)
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.visible = false
	add_child(root)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	center.add_child(box)
	var l := Label.new()
	l.text = title
	l.add_theme_font_size_override("font_size", 36)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(l)
	for b in buttons:
		var btn := Button.new()
		btn.text = b[0]
		btn.custom_minimum_size = Vector2(240, 48)
		btn.pressed.connect(b[1])
		box.add_child(btn)
	return root

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and GameState.in_run:
		if pause_panel.visible:
			_resume()
		else:
			pause_panel.visible = true
			get_tree().paused = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _show(panel: Control) -> void:
	await get_tree().create_timer(1.5).timeout   # let the day-end banner show first
	panel.visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _resume() -> void:
	pause_panel.visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()   # game.gd calls start_run() again

func _to_menu() -> void:
	get_tree().paused = false
	GameState.in_run = false
	GameState.running = false
	Audio.stop_music()
	get_tree().change_scene_to_file(MENU_SCENE)
