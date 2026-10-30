extends Node2D

var table: ChickenCross

func _ready() -> void:
	table = ChickenCross.new()
	add_child(table)
	table.lane_crossed.connect(func(l, m): print("Lane ", l, " x", m))
	table.busted.connect(func(l): print("BUST on lane ", l, " wallet ", GameState.wallet))
	table.cashed_out.connect(func(p): print("CASHED OUT ", p, " wallet ", GameState.wallet))
	GameState.start_run()
	print("B = bet 100, Space = push, C = cash out")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_B:
		print("Bet placed: ", table.start(100), " wallet ", GameState.wallet)
	elif event.is_action_pressed("push"):
		table.push()
	elif event.is_action_pressed("cash_out"):
		table.cash_out()
