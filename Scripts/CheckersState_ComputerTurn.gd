extends StateMachineState

var game_manager : SMSCheckers

func init(sms_checkers : SMSCheckers) -> void:
	game_manager = sms_checkers
	
func enter_state() -> void:
	super.enter_state()
	print("COMPUTER TURN")
	var game_state : CGameState = game_manager.generate_game_state()
	var best_move : MMCAction = game_manager.calc.get_best_action(game_state, 5)
	game_manager.commit_move(best_move)
