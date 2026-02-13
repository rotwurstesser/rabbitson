extends Node
## Manages global game state: current run, floor, turn count, pause.

enum GameState { MENU, PLAYING, PAUSED, GAME_OVER }

var current_state: GameState = GameState.MENU
var current_floor: int = 1
var current_turn: int = 0
var is_player_turn: bool = true


func start_new_run() -> void:
	current_floor = 1
	current_turn = 0
	is_player_turn = true
	current_state = GameState.PLAYING


func advance_turn() -> void:
	current_turn += 1
	is_player_turn = !is_player_turn
	if is_player_turn:
		EventBus.turn_started.emit(current_turn)
	else:
		EventBus.turn_ended.emit(current_turn)


func next_floor() -> void:
	current_floor += 1
	EventBus.floor_entered.emit(current_floor)


func game_over() -> void:
	current_state = GameState.GAME_OVER
