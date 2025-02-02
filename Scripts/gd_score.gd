class_name GDScore extends MMCScore

var our_hand_size : int = 0
var their_hand_size : int = 0

static func create(action : GDAction) -> GDScore:
	var score : GDScore = GDScore.new()
	score.our_hand_size = action.our_hand.size()
	score.their_hand_size = action.their_hand.size()
	return score

func reversed() -> MMCScore:
	var score : GDScore = GDScore.new()
	score.our_hand_size = their_hand_size
	score.their_hand_size = our_hand_size
	return score
	
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
	var our_diff : int = their_hand_size - our_hand_size
	var other_our_diff : int = other_gd.their_hand_size - other_gd.our_hand_size
	if our_diff != other_our_diff:
		return our_diff < other_our_diff
	return false
