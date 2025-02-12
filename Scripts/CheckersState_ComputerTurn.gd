extends StateMachineState

var game_manager : SMSCheckers
const search_depth : int = 3

func init(sms_checkers : SMSCheckers) -> void:
	game_manager = sms_checkers

# TODO: Move the calculation into the _process() after we spend a frame or two putting up the
# "I'm thinking" splash, and then take it down and wait a frame before calling commit_move()
func _process(_delta: float) -> void:
	pass
	
func enter_state() -> void:
	super.enter_state()
	var game_state : CGameState = game_manager.generate_game_state()
	var best_move : MMCAction = game_manager.calc.get_best_action(game_state, search_depth)
	game_manager.commit_move(best_move)
