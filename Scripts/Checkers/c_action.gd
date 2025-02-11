class_name CAction extends MMCAction

var checker : Checker
var moves : Array[Vector2i]
var game_state : CGameState
var score : CScore = null

static func create(c : Checker, dest : Vector2i, board : CGameState) -> CAction:
	var ret_val : CAction = CAction.new()
	ret_val.checker = c
	ret_val.moves.append(dest)
	ret_val.game_state = board
	return ret_val

func get_score() -> MMCScore:
	if score == null:
		var new_game_state : CGameState = game_state.apply_action(self) as CGameState
		score = CScore.create(new_game_state)
	return score
