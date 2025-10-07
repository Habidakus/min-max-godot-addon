class_name CScore extends MMCScore

var computer_piece_dominance : int = 0
var computer_vulnerable_piece_dominance : int = 0
var computer_danger_piece_dominance : int = 0
var computer_king_dominance : int = 0

static func create(game_state : CGameState) -> CScore:
	var ret_val : CScore = CScore.new()
	var board_values : Dictionary # Dict<Vector2i, side>
	for y in range(0, game_state.board_size):
		for x in range(0, game_state.board_size):
			if x % 2 == y % 2:
				continue
			board_values[Vector2i(x, y)] = 0
	for checker : Checker in game_state.pieces:
		if checker.alive:
			board_values[checker.square] = checker.side
			if checker.is_king():
				var computer_piece : bool = (checker.side == Checker.COMPUTER)
				if computer_piece:
					ret_val.computer_king_dominance += 1
				else:
					ret_val.computer_king_dominance -= 1
	for checker : Checker in game_state.pieces:
		if checker.alive:
			var computer_piece : bool = (checker.side == Checker.COMPUTER)
			if computer_piece:
				ret_val.computer_piece_dominance += 1
				var vul : Array[int] = how_vulnerable(checker, board_values)
				ret_val.computer_vulnerable_piece_dominance -= vul[0]
				ret_val.computer_danger_piece_dominance -= vul[1]
			else:
				ret_val.computer_piece_dominance -= 1
				var vul : Array[int] = how_vulnerable(checker, board_values)
				ret_val.computer_vulnerable_piece_dominance += vul[0]
				ret_val.computer_danger_piece_dominance += vul[1]
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
	ret_val.computer_piece_dominance = 0 - computer_piece_dominance
	ret_val.computer_king_dominance = 0 - computer_king_dominance
	ret_val.computer_danger_piece_dominance = 0 - computer_danger_piece_dominance
	ret_val.computer_vulnerable_piece_dominance = 0 - computer_vulnerable_piece_dominance
	return ret_val

func _to_string() -> String:
	return "k=" + str(computer_king_dominance) + "/p=" + str(computer_piece_dominance) + "/d=" + str(computer_danger_piece_dominance) + "/v=" + str(computer_vulnerable_piece_dominance)
	
func is_better_than(other : MMCScore) -> bool:
	var cother : CScore = other as CScore
	if computer_king_dominance != cother.computer_king_dominance:
		return computer_king_dominance > cother.computer_king_dominance
	if computer_piece_dominance != cother.computer_piece_dominance:
		return computer_piece_dominance > cother.computer_piece_dominance
	if computer_danger_piece_dominance != cother.computer_danger_piece_dominance:
		return computer_danger_piece_dominance > cother.computer_danger_piece_dominance
	if computer_vulnerable_piece_dominance != cother.computer_vulnerable_piece_dominance:
		return computer_vulnerable_piece_dominance > cother.computer_vulnerable_piece_dominance
	return false
