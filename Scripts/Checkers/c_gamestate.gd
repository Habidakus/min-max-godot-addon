class_name CGameState extends MMCGameState

var human_turn : bool
var pieces : Array[Checker]
var board_size : int

static func create(size : int, checkers : Array[Checker], human_is_active : bool) -> CGameState:
	var ret_val : CGameState = CGameState.new()
	ret_val.human_turn = human_is_active
	ret_val.pieces = checkers
	ret_val.board_size = size
	return ret_val

func apply_action(action : MMCAction) -> MMCGameState:
	var ret_val : CGameState = CGameState.new()
	ret_val.human_turn = !human_turn
	ret_val.board_size = board_size
	var move : CAction = action as CAction
	for checker : Checker in pieces:
		var clone : Checker = checker.clone()
		if checker == move.checker:
			clone.square = move.moves[move.moves.size() - 1]
		ret_val.pieces.append(clone)
	return ret_val

func is_valid_and_empty(square : Vector2i) -> bool:
	if square.x < 0 || square.x >= board_size:
		return false
	if square.y < 0 || square.y >= board_size:
		return false
	for checker : Checker in pieces:
		if checker.square == square:
			return false
	return true

func get_moves() -> Array[MMCAction]:
	var ret_val : Array[MMCAction]
	for checker : Checker in pieces:
		if (checker.side == 2) == human_turn:
			if checker.move_dir != 1:
				var dest = checker.square + Vector2i(-1, -1)
				if is_valid_and_empty(dest):
					ret_val.append(CAction.create(checker, dest, self))
				dest = checker.square + Vector2i(1, -1)
				if is_valid_and_empty(dest):
					ret_val.append(CAction.create(checker, dest, self))
			if checker.move_dir != -1:
				var dest = checker.square + Vector2i(-1, 1)
				if is_valid_and_empty(dest):
					ret_val.append(CAction.create(checker, dest, self))
				dest = checker.square + Vector2i(1, 1)
				if is_valid_and_empty(dest):
					ret_val.append(CAction.create(checker, dest, self))
	return ret_val

func get_score_for_current_player() -> MMCScore:
	return CScore.create(self).reversed()
