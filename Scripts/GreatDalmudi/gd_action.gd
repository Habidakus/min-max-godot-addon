class_name GDAction extends MMCAction

var rank : int
var score : GDScore

func get_score() -> MMCScore:
	return score

func _to_string() -> String:
	if rank <= 0:
		return "no valid moves, score = " + str(score)
	else:
		return "discard " + str(rank) + "s, score=" + str(score)
