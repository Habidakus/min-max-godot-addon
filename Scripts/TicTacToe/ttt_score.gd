class_name TTTScore extends MMCScore

# Compuer is playing O, Human is playing X

var x_victory : bool = false
var o_victory : bool = false
var x_twos : int = 0
var o_twos : int = 0
var x_ones : int = 0
var o_ones : int = 0

static func create(game_state : TTTGameState) -> TTTScore:
	var ret_val : TTTScore = TTTScore.new()
	for i in range(0, 3):
		ret_val.update(game_state.squares[0 + i * 3], game_state.squares[1 + i * 3], game_state.squares[2 + i * 3])
		ret_val.update(game_state.squares[0 + i], game_state.squares[3 + i], game_state.squares[6 + i])
	ret_val.update(game_state.squares[0], game_state.squares[4], game_state.squares[8])
	ret_val.update(game_state.squares[2], game_state.squares[4], game_state.squares[6])
	return ret_val

func update(v1 : int, v2 : int, v3 : int) -> void:
	var xs : int = 0
	var os : int = 0
	if v1 == 1:
		xs += 1
	elif v1 == -1:
		os += 1
	if v2 == 1:
		xs += 1
	elif v2 == -1:
		os += 1
	if v3 == 1:
		xs += 1
	elif v3 == -1:
		os += 1

	if xs == 3:
		x_victory = true
	elif os == 3:
		o_victory = true
	elif xs == 2:
		if os == 0:
			x_twos += 1
	elif os == 2:
		if xs == 0:
			o_twos += 1
	elif xs == 1:
		if os == 0:
			x_ones += 1
	elif os == 1:
		if xs == 0:
			o_ones += 1

## Return the inverse of the current score.
func reversed() -> MMCScore:
	var ret_val : TTTScore = TTTScore.new()
	# Really? Will this work?
	ret_val.x_victory = o_victory
	ret_val.o_victory = x_victory
	ret_val.x_twos = o_twos
	ret_val.o_twos = x_twos
	ret_val.x_ones = o_ones
	ret_val.o_ones = x_ones
	return ret_val
	
## Returns true only if the current score is better for the Computer Player (the one we're doing all
## this computation for) than it would be for the human opponent.
func is_better_than(other : MMCScore) -> bool:
	var other_ttt : TTTScore = other as TTTScore
	if o_victory != other_ttt.o_victory:
		return o_victory
	if x_victory != other_ttt.x_victory:
		return other_ttt.x_victory
	if o_twos != other_ttt.o_twos:
		return o_twos > other_ttt.o_twos
	if x_twos != other_ttt.x_twos:
		return other_ttt.x_twos > x_twos
	if o_ones != other_ttt.o_ones:
		return o_ones > other_ttt.o_ones
	if x_ones != other_ttt.x_ones:
		return other_ttt.x_ones > x_ones
	return false
