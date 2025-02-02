class_name TTTAction extends MMCAction

var xs_turn : bool
var squares : Array[int] = [0, 0, 0, 0, 0, 0, 0, 0, 0]

static func start(x : int, y : int) -> TTTAction:
	var ret_val : TTTAction = TTTAction.new()
	ret_val.xs_turn = true
	ret_val.squares[x + y * 3] = 1
	return ret_val

func dump() -> void:
	print("---")
	dump_row(0)
	dump_row(3)
	dump_row(6)

func dump_row(s : int) -> void:
	var d : String = ""
	for v in range(s, s + 3):
		d = d + dump_cell(v)
	print(d)

func dump_cell(c : int) -> String:
	if squares[c] == 0:
		return " "
	elif squares[c] == 1:
		return "X"
	elif squares[c] == -1:
		return "O"
	else:
		return "?"

func get_score() -> MMCScore:
	# Should evaluate how good the current action leaves the game for the acting player
	return TTTScore.create(self)

func get_followup_moves() -> Array[MMCAction]:
	var place_value : int = -1 if xs_turn else 1
	var ret_val : Array[MMCAction]
	for i in squares.size():
		if squares[i] == 0:
			var opponent_move : TTTAction = TTTAction.new()
			opponent_move.xs_turn = xs_turn == false
			for j in squares.size():
				opponent_move.squares[j] = squares[j]
			opponent_move.squares[i] = place_value
			ret_val.append(opponent_move)
	return ret_val
