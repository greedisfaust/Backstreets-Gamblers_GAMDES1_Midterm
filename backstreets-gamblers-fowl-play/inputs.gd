extends Node
# Registers the named Input Map actions from GDD 8.3 (primary + alternate).

const KEYS := {
	"move_forward": [KEY_W, KEY_UP],
	"move_back": [KEY_S, KEY_DOWN],
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"look_left": [KEY_J],
	"look_right": [KEY_L],
	"look_up": [KEY_I],
	"look_down": [KEY_K],
	"interact": [KEY_E, KEY_F],
	"hit": [KEY_Q],
	"push": [KEY_SPACE],
	"cash_out": [KEY_C],
	"pause": [KEY_ESCAPE, KEY_P],
	"bet_up": [KEY_UP],
	"bet_down": [KEY_DOWN],
}
const MOUSE := {
	"hit": MOUSE_BUTTON_LEFT,
	"push": MOUSE_BUTTON_LEFT,
	"cash_out": MOUSE_BUTTON_RIGHT,
	"bet_up": MOUSE_BUTTON_WHEEL_UP,
	"bet_down": MOUSE_BUTTON_WHEEL_DOWN,
}

func _ready() -> void:
	for action in KEYS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for k in KEYS[action]:
			var e := InputEventKey.new()
			e.physical_keycode = k
			InputMap.action_add_event(action, e)
	for action in MOUSE:
		var m := InputEventMouseButton.new()
		m.button_index = MOUSE[action]
		InputMap.action_add_event(action, m)
