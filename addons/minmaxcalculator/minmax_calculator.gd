class_name MinMaxCalculator extends Object

# Implementation of https://en.wikipedia.org/wiki/Negamax

const max_int : int = 9223372036854775807

func get_best_action(game_state : MMCGameState, depth : int = max_int) -> MMCAction:
	var result : MMCResult = get_best_action_internal(game_state, MMCScore.LOWEST, MMCScore.HIGHEST, depth)
	if result == null:
		return null
	else:
		return result.action

func get_best_action_internal(game_state : MMCGameState, actorsLowerBound: MMCScore, actorsUpperBound: MMCScore, depth : int) -> MMCResult:
	var actions : Array[MMCAction] = game_state.get_moves()
	if actions.is_empty():
		# Action is a terminal (leaf) action, so there are no counters to it
		return MMCResult.create_score_only(game_state.get_score_for_current_player())
	
	actions.sort_custom(func(a : MMCAction, b : MMCAction) : return a.get_score().is_better_than(b.get_score()))
	
	#print("vvv")
	#for action in actions:
		#var post_action_state : MMCGameState = game_state.apply_action(action)
		#post_action_state.dump()
	#print("^^^")
	
	var best : MMCResult = null
	for i : int in range(0, actions.size()):
		var action : MMCAction = actions[i]
		var post_action_state : MMCGameState = game_state.apply_action(action)
		var actorsUpperBoundReversed : MMCScore = actorsUpperBound.reversed()
		var actorsLowerBoundReversed : MMCScore = actorsLowerBound.reversed()
		var result : MMCResult = get_best_action_internal(post_action_state, actorsUpperBoundReversed, actorsLowerBoundReversed, depth - 1)
		var result_score : MMCScore = result.score.reversed()
		if best == null:
			best = MMCResult.create(action, result_score)
		elif result_score.is_better_than(best.score):
			best = MMCResult.create(action, result_score)
		if MMCScore.is_first_better_than_second(result_score, actorsLowerBound):
			actorsLowerBound = result_score
		if MMCScore.is_first_better_than_or_equal_to_second(actorsLowerBound, actorsUpperBound):
			return best
			
	return best
