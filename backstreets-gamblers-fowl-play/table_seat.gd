extends Area3D
# Interaction area for the Chicken Cross table: sit, bet, push, cash out.

var table: ChickenCross
var player: Node = null
var seated := false
var bet := 100

func _ready() -> void:
	table = ChickenCross.new()
	add_child(table)
	table.lane_crossed.connect(func(l, m):
		GameState.message.emit("Lane %d cleared  x%.1f" % [l, m])
		Audio.play("step"))
	table.busted.connect(func(l):
		GameState.message.emit("BUST on lane %d - bet lost" % l)
		Audio.play("bust"))
	table.cashed_out.connect(func(p):
		GameState.message.emit("CASHED OUT +%d" % p)
		Audio.play("win"))
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)
	GameState.day_ended.connect(_on_day_ended)

func _on_enter(b: Node3D) -> void:
	if b.is_in_group("player"):
		player = b
		_show_status()

func _on_exit(b: Node3D) -> void:
	if b == player:
		if seated:
			_stand()
		player = null
		_show_status()

func _on_day_ended(_met) -> void:
	if seated:
		_stand()

func _step() -> int:
	return maxi(10, int(GameState.max_bet() / 10.0 / 10.0) * 10)

func _sit() -> void:
	seated = true
	player.can_move = false
	bet = clampi(bet, 10, maxi(10, GameState.max_bet()))

func _stand() -> void:
	seated = false
	table.active = false   # leaving mid-round forfeits the bet
	player.can_move = true

func _unhandled_input(event: InputEvent) -> void:
	if player == null or not GameState.running:
		return
	if event.is_action_pressed("interact"):
		if not seated:
			_sit()
		elif not table.active:
			_stand()
	elif seated:
		if not table.active:
			if event.is_action_pressed("bet_up"):
				bet = mini(bet + _step(), GameState.max_bet())
			elif event.is_action_pressed("bet_down"):
				bet = maxi(bet - _step(), 10)
			elif event.is_action_pressed("push"):
				bet = mini(bet, GameState.max_bet())
				if table.start(bet):
					Audio.play("bet")
				else:
					GameState.message.emit("Can't place that bet")
		else:
			if event.is_action_pressed("push"):
				table.push()
			elif event.is_action_pressed("cash_out"):
				table.cash_out()
	_show_status()

func _show_status() -> void:
	if not seated:
		GameState.table_status.emit("[E] Sit at Chicken Cross" if player else "")
	elif table.active:
		var mult: float = 0.0 if table.lane == 0 else ChickenCross.MULT[table.lane - 1]
		var next_bust := int(ChickenCross.BUST[table.lane] * 100)
		GameState.table_status.emit("Bet %d | Lane %d/12 | x%.1f | Banked %d\nNext lane bust chance: %d%%\n[Space] push    [C] cash out" % [table.bet, table.lane, mult, int(table.bet * mult), next_bust])
	else:
		GameState.table_status.emit("Chicken Cross | Bet %d (max %d)\n[Up/Down or wheel] change bet    [Space] place bet    [E] leave" % [bet, GameState.max_bet()])
