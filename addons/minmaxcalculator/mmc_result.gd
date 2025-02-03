class_name MMCResult extends Object

var action : MMCAction = null
var score : MMCScore = null

static func create(a : MMCAction, s : MMCScore) -> MMCResult:
	var ret_val : MMCResult = MMCResult.new()
	ret_val.action = a
	ret_val.score = s
	return ret_val

static func create_score_only(s : MMCScore) -> MMCResult:
	var ret_val : MMCResult = MMCResult.new()
	ret_val.score = s
	return ret_val

func reverse_score() -> void:
	score = score.reversed()
