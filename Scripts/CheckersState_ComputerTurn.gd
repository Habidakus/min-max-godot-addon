extends StateMachineState

var game_manager : SMSCheckers
const search_depth : int = 5

func init(sms_checkers : SMSCheckers) -> void:
	game_manager = sms_checkers
	
func enter_state() -> void:
	super.enter_state()
	var game_state : CGameState = game_manager.generate_game_state()
	var best_move : MMCAction = game_manager.calc.get_best_action(game_state, search_depth)
	game_manager.commit_move(best_move)
