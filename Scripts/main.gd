extends Control

var calc : MinMaxCalculator = MinMaxCalculator.new()
var completed : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var game_state : GDGameState = GDGameState.create_initial_state(132)
	#var game_state : TTTGameState = TTTGameState.create_initial_state()
	var action : MMCAction = calc.get_best_action(game_state)
	while action != null:
		var next_game_state : MMCGameState = game_state.apply_action(action)
		print("---")
		next_game_state.dump()
		var counter : MMCAction = calc.get_best_action(next_game_state)
		action = counter
		game_state = next_game_state
	print("No more follow-up moves")
