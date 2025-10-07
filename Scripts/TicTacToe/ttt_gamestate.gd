class_name TTTGameState extends MMCGameState

var xs_turn : bool
var squares : Array[int]

static func create_initial_state() -> TTTGameState:
	var ret_val : TTTGameState = TTTGameState.new()
	ret_val.xs_turn = true
	ret_val.squares = [0,0,0,0,0,0,0,0,0]
	return ret_val

func dump() -> void:
	for i in range(0, 3):
		dump_row(i)

func dump_row(row : int) -> void:
	var row_text : String = ""
	for i in range(row * 3, row * 3 + 3):
		row_text += dump_square(i)
	print(row_text)

func dump_square(square : int) -> String:
	if squares[square] == 1:
		return "X"
	elif squares[square] == -1:
		return "O"
	else:
		return " "

func apply_action(action : MMCAction) -> MMCGameState:
	var ret_val : TTTGameState = TTTGameState.new()
	for i in squares.size():
		if i == action.square:
			var value : int = 1 if xs_turn else -1
			ret_val.squares.append(value)
		else:
			ret_val.squares.append(squares[i])
	ret_val.xs_turn = !xs_turn
	return ret_val

func is_ended() -> bool:
	var score : TTTScore = TTTScore.create(self)
	if score.x_victory || score.o_victory:
		return true
	for i in squares.size():
		if squares[i] == 0:
			return false
	return true

## Returns the list of all legal moves that the current player could make in the current game state.
## Ideally you should sort the moves so that the best moves for the current player (indicated by the
## [_for_computer_player] argument) are first, and the worst moves are last.
func get_sorted_moves(_for_computer_player : bool) -> Array[MMCAction]:
	var ret_val : Array[MMCAction]
	var current_score : TTTScore = TTTScore.create(self)
	if current_score.x_victory || current_score.x_victory:
		return ret_val
	for i in squares.size():
		if squares[i] == 0:
			var move : TTTAction = TTTAction.new()
			move.square = i
			move.score = TTTScore.create(apply_action(move))
			ret_val.append(move)
	return ret_val

func get_score() -> MMCScore:
	return TTTScore.create(self)
