class_name ChickenCross
extends Node
# Chicken Cross table logic (GDD 6.4): 12 lanes, press-your-luck.

signal bet_placed(player_id, table_id, amount)
signal bet_resolved(table_id, payout)
signal lane_crossed(lane, multiplier)
signal busted(lane)
signal cashed_out(payout)

const TABLE_ID := "chicken_cross"
const BUST := [0.07, 0.09, 0.11, 0.14, 0.17, 0.20, 0.24, 0.28, 0.32, 0.37, 0.42, 0.48]
const MULT := [1.3, 1.7, 1.9, 2.2, 2.5, 2.9, 3.4, 3.8, 4.7, 6.0, 8.5, 15.0]

var active := false
var bet := 0
var lane := 0   # lanes crossed so far

func _ready() -> void:
	bet_placed.connect(GameState.on_bet_placed)
	bet_resolved.connect(GameState.on_bet_resolved)

func start(amount: int, player_id: int = 1) -> bool:
	if active or amount <= 0 or amount > GameState.max_bet():
		return false
	bet = amount
	lane = 0
	active = true
	bet_placed.emit(player_id, TABLE_ID, amount)
	return true

func push() -> void:
	if not active:
		return
	if randf() < BUST[lane]:
		active = false
		busted.emit(lane + 1)
		bet_resolved.emit(TABLE_ID, 0)
		return
	lane += 1
	lane_crossed.emit(lane, MULT[lane - 1])
	if lane == 12:
		cash_out()   # auto cash-out at the last lane

func cash_out() -> void:
	if not active or lane == 0:
		return
	var payout := int(bet * MULT[lane - 1])
	active = false
	bet_resolved.emit(TABLE_ID, payout)
	cashed_out.emit(payout)
