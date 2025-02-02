class_name MinMaxCalculator extends Object

# Implementation of https://en.wikipedia.org/wiki/Negamax

const max_int : int = 9223372036854775807

func get_best_action(action : MMCAction, depth : int = max_int) -> MMCAction:
	var result : MMCResult = get_best_action_internal(action, null, null, depth)
	return result.action

func get_best_action_internal(action : MMCAction, actorsLowerBound: MMCScore, actorsUpperBound: MMCScore, depth : int) -> MMCResult:
	if depth == 0:
		return MMCResult.create(action, action.get_score())
	
	var counters : Array[MMCAction] = action.get_followup_moves()
	if counters.is_empty():
		# Action is a terminal (leaf) action, so there are no counters to it
		return MMCResult.create(action, action.get_score())

	counters.sort_custom(func(a : MMCAction,b : MMCAction) : return a.get_score().is_better_than(b.get_score()))
	var best : MMCResult = null
	for counter in counters:
		var actorsUpperBoundReversed : MMCScore = null if actorsUpperBound == null else actorsUpperBound.reversed()
		var actorsLowerBoundReversed : MMCScore = null if actorsLowerBound == null else actorsLowerBound.reversed()
		var result : MMCResult = get_best_action_internal(counter, actorsUpperBoundReversed, actorsLowerBoundReversed, depth - 1)
		result.reverse_score()
		if best == null:
			best = MMCResult.create(counter, result.score)
		elif result.score.is_better_than(best.score):
			best = MMCResult.create(counter, result.score)
		if actorsLowerBound == null or result.score.is_better_than(actorsLowerBound):
			actorsLowerBound = result.score
		if actorsUpperBound == null or actorsLowerBound.is_better_than_or_equal(actorsUpperBound):
			return best
	return best
