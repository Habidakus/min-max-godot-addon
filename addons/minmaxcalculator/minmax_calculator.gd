class_name MinMaxCalculator extends Object

# Implementation of https://en.wikipedia.org/wiki/Negamax

const max_int : int = 9223372036854775807

func get_best_action(game_state : MMCGameState, depth : int = max_int, debug : MMCDebug = null) -> MMCAction:
	var result : MMCResult = get_best_action_internal(game_state, MMCScore.LOWEST, MMCScore.HIGHEST, depth, debug)
	if result == null:
		return null
	else:
		return result.action

func get_best_action_internal(game_state : MMCGameState, actorsLowerBound: MMCScore, actorsUpperBound: MMCScore, depth : int, debug : MMCDebug) -> MMCResult:
	var actions : Array[MMCAction] = game_state.get_moves()
	if debug != null:
		debug.add_actions(game_state, actions)
	if actions.is_empty() || depth == 0:
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
		var result : MMCResult = get_best_action_internal(post_action_state, actorsUpperBoundReversed, actorsLowerBoundReversed, depth - 1, debug)
		# TODO: Why are we reversing things here, it just makes the MMCAction.get_score() wierd as it has to compute backwards as well
		var result_score : MMCScore = result.score.reversed()
		if debug != null:
			debug.add_result(game_state, action, post_action_state, result_score)
		if best == null:
			best = MMCResult.create(action, result_score)
		elif result_score.is_better_than(best.score):
			best = MMCResult.create(action, result_score)
		if MMCScore.is_first_better_than_second(result_score, actorsLowerBound):
			actorsLowerBound = result_score
		if MMCScore.is_first_better_than_or_equal_to_second(actorsLowerBound, actorsUpperBound):
			return best
			
	return best
