extends Node
# Central game state (autoload). All HUD/menus listen to its signals (GDD 8.5).

signal wallet_changed(balance)
signal day_started(day, quota, open_time)
signal time_changed(time_left)
signal quota_status_changed(is_met)
signal day_ended(quota_met)
signal extra_life_spent
signal run_won
signal game_over
signal message(text)
signal table_status(text)

const MULTIPLIERS := [1.25, 1.28, 1.32, 1.36, 1.40, 1.45, 1.50, 1.55, 1.62, 1.70]
const START_WALLET := 1000
const HIT_COST_PCT := 0.005
var day_time := 300.0   # use 30.0 while testing, set back to 300.0 before submitting

var wallet := 0
var day := 1
var day_start_wallet := 0
var quota_basis := 0
var quota := 0
var time_left := 0.0
var extra_life := true
var running := false
var in_run := false
var penalty_next := false

func start_run() -> void:
	wallet = START_WALLET
	day = 1
	extra_life = true
	in_run = true
	penalty_next = false
	_begin_day()

func _begin_day() -> void:
	if not in_run:
		return
	day_start_wallet = wallet
	if not penalty_next:
		quota_basis = day_start_wallet   # normal day: quota from day-start wallet
	penalty_next = false                 # after a miss, basis stays the failed day's wallet
	quota = int(round(quota_basis * MULTIPLIERS[day - 1]))
	time_left = day_time
	running = true
	day_started.emit(day, quota, time_left)
	wallet_changed.emit(wallet)
	quota_status_changed.emit(wallet >= quota)

func _process(delta: float) -> void:
	if not running:
		return
	time_left -= delta
	time_changed.emit(time_left)
	if time_left <= 0.0:
		end_day()

func max_bet() -> int:
	# half of quota, rounded down to nearest 10, never more than the wallet
	var cap := int(floor(quota * 0.5 / 10.0)) * 10
	return min(wallet, cap)

func spend_bet(amount: int) -> bool:
	if amount <= 0 or amount > max_bet():
		return false
	add_wallet(-amount)
	return true

func add_wallet(amount: int) -> void:
	wallet = max(0, wallet + amount)
	wallet_changed.emit(wallet)
	quota_status_changed.emit(wallet >= quota)

func apply_hit() -> void:
	add_wallet(-int(round(quota * HIT_COST_PCT)))   # gone for good

func try_early_end() -> void:
	# called by the exit zone when all players are inside
	if running and wallet >= quota:
		end_day()

func end_day() -> void:
	if not running:
		return
	running = false
	var met := wallet >= quota
	day_ended.emit(met)
	if met:
		if day >= 10:
			in_run = false
			run_won.emit()
			return
		day += 1
	else:
		if extra_life:
			extra_life = false
			wallet = int(floor(day_start_wallet / 2.0))
			penalty_next = true
			extra_life_spent.emit()
			wallet_changed.emit(wallet)
			# Day 10: one final attempt, so the day number stays at 10
			if day < 10:
				day += 1
		else:
			in_run = false
			game_over.emit()
			return
	get_tree().create_timer(3.0).timeout.connect(_begin_day)
	
	
func on_bet_placed(_player_id, _table_id, amount: int) -> void:
	add_wallet(-amount)

func on_bet_resolved(_table_id, payout: int) -> void:
	if payout > 0:
		add_wallet(payout)
