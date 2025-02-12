class_name CAction extends MMCAction

var checker : Checker
var foes : Array[Checker]
var moves : Array[Vector2i]
var game_state : CGameState
var score : CScore = null

static func create_move(c : Checker, dest : Vector2i, board : CGameState) -> CAction:
	var ret_val : CAction = CAction.new()
	ret_val.checker = c
	ret_val.game_state = board
	ret_val.moves.append(dest)
	return ret_val

static func create_attack(c : Checker, journey : Array[Array], board : CGameState) -> CAction:
	var ret_val : CAction = CAction.new()
	ret_val.checker = c
	ret_val.game_state = board
	for entry : Array in journey:
		ret_val.foes.append(entry[0])
		ret_val.moves.append(entry[1])
	return ret_val

func get_final_location() -> Vector2i:
	return moves[moves.size() - 1]

func get_score() -> MMCScore:
	if score == null:
		var new_game_state : CGameState = game_state.apply_action(self) as CGameState
		score = CScore.create(new_game_state)
	return score
