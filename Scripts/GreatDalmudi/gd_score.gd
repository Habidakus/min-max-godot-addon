class_name GDScore extends MMCScore

var human_hand_size : int = 0
var human_hand_total : int = 0
var ai_hand_size : int = 0
var ai_hand_total : int = 0

static func create(game_state : GDGameState) -> MMCScore:
	var score : GDScore = GDScore.new()
	
	for card : int in game_state.ai_hand:
		score.ai_hand_size += 1
		score.ai_hand_total += card
	for card : int in game_state.human_hand:
		score.human_hand_size += 1
		score.human_hand_total += card
	assert(!(score.human_hand_size == 0 && score.ai_hand_size == 0))
	return score

func reversed() -> MMCScore:
	var score : GDScore = GDScore.new()
	score.human_hand_size = ai_hand_size
	score.human_hand_total = ai_hand_total
	score.ai_hand_size = human_hand_size
	score.ai_hand_total = human_hand_total
	return score

func is_better_than(other : MMCScore) -> bool:
	var other_gd : GDScore = other as GDScore
	var we_won : bool = ai_hand_size == 0
	var other_we_won : bool = other_gd.ai_hand_size == 0
	if we_won != other_we_won:
		return we_won
		
	var they_won : bool = human_hand_size == 0
	var other_they_won : bool = other_gd.human_hand_size == 0
	if they_won != other_they_won:
		return other_they_won
		
	var our_diff : int = human_hand_size - ai_hand_size
	var other_our_diff : int = other_gd.human_hand_size - other_gd.ai_hand_size
	if our_diff != other_our_diff:
		return our_diff > other_our_diff
		
	our_diff = human_hand_total - ai_hand_total
	other_our_diff = other_gd.human_hand_total - other_gd.ai_hand_total
	if our_diff != other_our_diff:
		return our_diff > other_our_diff
		
	return false
