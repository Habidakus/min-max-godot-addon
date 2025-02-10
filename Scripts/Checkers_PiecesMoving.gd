extends StateMachineState

var game_manager : SMSCheckers

func init(game : SMSCheckers) -> void:
	game_manager = game
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !game_manager.move_pieces(delta):
		game_manager.transition_to_next_turn()
