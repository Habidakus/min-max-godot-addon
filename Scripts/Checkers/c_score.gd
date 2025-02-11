class_name CScore extends MMCScore

var piece_dominance : int = 0
var vulnerable_piece_dominance : int = 0
var danger_piece_dominance : int = 0
var king_dominance : int = 0

static func create(game_state : CGameState) -> CScore:
	var ret_val : CScore = CScore.new()
	var board_values : Dictionary # Dict<Vector2i, side>
	for checker : Checker in game_state.pieces:
		board_values[checker.square] = checker.side
		if checker.move_dir == 0:
			var our_piece : bool = (checker.side == 2) == game_state.human_turn
			if our_piece:
				ret_val.king_dominance += 1
			else:
				ret_val.king_dominance -= 1
	for checker : Checker in game_state.pieces:
		var our_piece : bool = (checker.side == 2) == game_state.human_turn
		if our_piece:
			ret_val.piece_dominance += 1
			var vul : Array = how_vulnerable(checker, board_values)
			ret_val.vulnerable_piece_dominance -= vul[0]
			ret_val.danger_piece_dominance -= vul[1]
		else:
			ret_val.piece_dominance -= 1
			var vul : Array = how_vulnerable(checker, board_values)
			ret_val.vulnerable_piece_dominance += vul[0]
			ret_val.danger_piece_dominance += vul[1]
	return ret_val

static func how_vulnerable(checker : Checker, board : Dictionary) -> Array[int]:
	var vulnerable : int = 0
	var immediate : int = 0
	var square : Vector2i = checker.square
	if board.has(square + Vector2i.ONE) && board.has(square - Vector2i.ONE):
		var pp : int = board[square + Vector2i.ONE]
		var nn : int = board[square - Vector2i.ONE]
		if pp != checker.side && nn != checker.side:
			if pp != nn:
				immediate += 1
			else:
				vulnerable += 1
	if board.has(square + Vector2i(1, -1)) && board.has(square + Vector2i(-1, 1)):
		var pn : int = board[square + Vector2i(1, -1)]
		var np : int = board[square + Vector2i(-1, 1)]
		if pn != checker.side && np != checker.side:
			if np != pn:
				immediate += 1
			else:
				vulnerable += 1
	var ret_val : Array[int]
	ret_val.append(vulnerable)
	ret_val.append(immediate)
	return ret_val
	
func reversed() -> MMCScore:
	var ret_val : CScore = CScore.new()
	ret_val.piece_dominance = 0 - piece_dominance
	ret_val.king_dominance = 0 - king_dominance
	ret_val.danger_piece_dominance = 0 - danger_piece_dominance
	ret_val.vulnerable_piece_dominance = 0 - vulnerable_piece_dominance
	return ret_val
	
func is_better_than(other : MMCScore) -> bool:
	var cother : CScore = other as CScore
	if king_dominance != cother.king_dominance:
		return king_dominance > 0
	if piece_dominance != cother.piece_dominance:
		return piece_dominance > 0
	if danger_piece_dominance != cother.danger_piece_dominance:
		return danger_piece_dominance > 0
	if vulnerable_piece_dominance != cother.vulnerable_piece_dominance:
		return vulnerable_piece_dominance > 0
	return false
