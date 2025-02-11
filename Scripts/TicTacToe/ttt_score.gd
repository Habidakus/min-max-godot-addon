class_name TTTScore extends MMCScore

var is_victory : bool = false
var is_loss : bool = false
var number_of_our_unblocked_two_in_a_line : int = 0
var number_of_their_unblocked_two_in_a_line : int = 0
var number_of_our_unblocked_solos : int = 0
var number_of_their_unblocked_solos : int = 0

static func create(game_state : TTTGameState) -> TTTScore:
	var ret_val : TTTScore = TTTScore.new()
	for i in range(0, 3):
		ret_val.update(game_state.xs_turn, game_state.squares[0 + i * 3], game_state.squares[1 + i * 3], game_state.squares[2 + i * 3])
		ret_val.update(game_state.xs_turn, game_state.squares[0 + i], game_state.squares[3 + i], game_state.squares[6 + i])
	ret_val.update(game_state.xs_turn, game_state.squares[0], game_state.squares[4], game_state.squares[8])
	ret_val.update(game_state.xs_turn, game_state.squares[2], game_state.squares[4], game_state.squares[6])
	return ret_val

func update(xs_turn : bool, v1 : int, v2 : int, v3 : int) -> void:
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
		is_victory = is_victory or xs_turn
		is_loss = is_loss or !xs_turn
	elif os == 3:
		is_victory = is_victory or !xs_turn
		is_loss = is_loss or xs_turn
	elif xs_turn:
		if xs == 0:
			if os == 1:
				number_of_their_unblocked_solos += 1
			elif os == 2:
				number_of_their_unblocked_two_in_a_line += 1
		elif os == 0:
			if xs == 1:
				number_of_our_unblocked_solos += 1
			elif xs == 2:
				number_of_our_unblocked_two_in_a_line += 1
	else:
		if xs == 0:
			if os == 1:
				number_of_our_unblocked_solos += 1
			elif os == 2:
				number_of_our_unblocked_two_in_a_line += 1
		elif os == 0:
			if xs == 1:
				number_of_their_unblocked_solos += 1
			elif xs == 2:
				number_of_their_unblocked_two_in_a_line += 1

func _to_string() -> String:
	var ret_val : String = ""
	if is_victory:
		ret_val += "victory"
	elif is_loss:
		ret_val += "loss"
	if !ret_val.is_empty():
		ret_val += " "
	ret_val += str(number_of_our_unblocked_two_in_a_line) + "/" + str(number_of_our_unblocked_solos) + "//" + str(number_of_their_unblocked_solos) + "/" + str(number_of_their_unblocked_two_in_a_line)
	return ret_val
	
func reversed() -> MMCScore:
	var ret_val : TTTScore = TTTScore.new()
	ret_val.is_victory = is_loss
	ret_val.is_loss = is_victory
	ret_val.number_of_our_unblocked_two_in_a_line = number_of_their_unblocked_two_in_a_line
	ret_val.number_of_their_unblocked_two_in_a_line = number_of_our_unblocked_two_in_a_line
	ret_val.number_of_our_unblocked_solos = number_of_their_unblocked_solos
	ret_val.number_of_their_unblocked_solos = number_of_our_unblocked_solos
	return ret_val
	
func is_better_than(other : MMCScore) -> bool:
	var other_ttt : TTTScore = other as TTTScore
	if is_victory != other_ttt.is_victory:
		return is_victory
	if is_loss != other_ttt.is_loss:
		return other_ttt.is_loss
	#if number_of_their_unblocked_two_in_a_line != other_ttt.number_of_their_unblocked_two_in_a_line:
		#return other_ttt.number_of_their_unblocked_two_in_a_line > number_of_their_unblocked_two_in_a_line
	#if number_of_our_unblocked_two_in_a_line != other_ttt.number_of_our_unblocked_two_in_a_line:
		#return number_of_our_unblocked_two_in_a_line > other_ttt.number_of_our_unblocked_two_in_a_line
	#if number_of_their_unblocked_solos != other_ttt.number_of_their_unblocked_solos:
		#return other_ttt.number_of_their_unblocked_solos > number_of_their_unblocked_solos
	#if number_of_our_unblocked_solos != other_ttt.number_of_our_unblocked_solos:
		#return number_of_our_unblocked_solos > other_ttt.number_of_our_unblocked_solos
	
	return false
