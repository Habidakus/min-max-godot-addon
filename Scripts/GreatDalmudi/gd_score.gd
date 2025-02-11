class_name GDScore extends MMCScore

var our_hand_size : int = 0
var our_hand_total : int = 0
var their_hand_size : int = 0
var their_hand_total : int = 0

static func create(game_state : GDGameState) -> MMCScore:
	var score : GDScore = GDScore.new()
	var for_player_one : bool = game_state.player_1_turn
	
	for card : int in game_state.player_1_hand:
		if for_player_one:
			score.our_hand_size += 1
			score.our_hand_total += card
		else:
			score.their_hand_size += 1
			score.their_hand_total += card
	for card : int in game_state.player_2_hand:
		if !for_player_one:
			score.our_hand_size += 1
			score.our_hand_total += card
		else:
			score.their_hand_size += 1
			score.their_hand_total += card
	assert(!(score.our_hand_size == 0 && score.their_hand_size == 0))
	return score

func reversed() -> MMCScore:
	var score : GDScore = GDScore.new()
	score.our_hand_size = their_hand_size
	score.our_hand_total = their_hand_total
	score.their_hand_size = our_hand_size
	score.their_hand_total = our_hand_total
	return score

func _to_string() -> String:
	if our_hand_size == 0:
		return "VICTORY"
	elif their_hand_size == 0:
		return "LOSS"
	elif our_hand_total > their_hand_total:
		return "bloated hand"
	elif their_hand_total > our_hand_total:
		return "lean hand"
	else:
		return "unknown"
	
func is_better_than(other : MMCScore) -> bool:
	var other_gd : GDScore = other as GDScore
	var we_won : bool = our_hand_size == 0
	var other_we_won : bool = other_gd.our_hand_size == 0
	if we_won != other_we_won:
		return we_won
	var they_won : bool = their_hand_size == 0
	var other_they_won : bool = other_gd.their_hand_size == 0
	if they_won != other_they_won:
		return other_they_won
	#var our_diff : int = their_hand_size - our_hand_size
	#var other_our_diff : int = other_gd.their_hand_size - other_gd.our_hand_size
	#if our_diff != other_our_diff:
		#return our_diff < other_our_diff
	#our_diff = their_hand_total - our_hand_total
	#other_our_diff = other_gd.their_hand_total - other_gd.our_hand_total
	#if our_diff != other_our_diff:
		#return our_diff < other_our_diff
	return false
