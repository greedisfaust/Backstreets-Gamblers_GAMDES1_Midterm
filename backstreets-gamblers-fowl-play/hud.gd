extends CanvasLayer
# HUD (GDD 3.4/8.4): wallet vs quota, timer, day, extra life, table prompts. Listens to GameState signals.

var info: Label
var message: Label
var table_label: Label
var day := 1
var quota := 0
var wallet := 0
var time_left := 0.0
var extra := true

func _ready() -> void:
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(box)
	info = _label(box, 22, HORIZONTAL_ALIGNMENT_LEFT)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(spacer)
	message = _label(box, 30, HORIZONTAL_ALIGNMENT_CENTER)
	table_label = _label(box, 22, HORIZONTAL_ALIGNMENT_CENTER)
	GameState.wallet_changed.connect(func(b): wallet = b; _update())
	GameState.day_started.connect(_on_day_started)
	GameState.time_changed.connect(func(t): time_left = t; _update())
	GameState.quota_status_changed.connect(func(met): info.modulate = Color.LIME_GREEN if met else Color.WHITE)
	GameState.extra_life_spent.connect(_on_extra_spent)
	GameState.day_ended.connect(func(met): _say("Quota met!" if met else "Quota MISSED!"))
	GameState.message.connect(_say)
	GameState.table_status.connect(func(t): table_label.text = t)

func _label(parent: Node, size: int, align: HorizontalAlignment) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 6)
	l.horizontal_alignment = align
	parent.add_child(l)
	return l

func _on_day_started(d: int, q: int, _t) -> void:
	day = d
	quota = q
	extra = GameState.extra_life
	_say("DAY %d - quota %d" % [d, q])
	_update()

func _on_extra_spent() -> void:
	extra = false
	_say("EXTRA LIFE SPENT - wallet halved")
	_update()

func _say(text: String) -> void:
	message.text = text
	get_tree().create_timer(2.5).timeout.connect(func(): message.text = "")

func _update() -> void:
	var t := maxi(0, ceili(time_left))
	info.text = "Day %d/10    Wallet %d / Quota %d    Time %d:%02d    Extra life: %s" % [day, wallet, quota, floori(t / 60.0), t % 60, "YES" if extra else "USED"]
